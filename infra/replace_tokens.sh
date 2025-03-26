#!/bin/bash

# Define the prefix and suffix
PREFIX="\[__"
SUFFIX="__\]"

# Path to the YAML file containing variable definitions
YAML_FILE=$1

# Path to the pipeline control file
PIPELINE_FILE="pipeline.yaml"

# Create a temporary directory
TMP_DIR=$(mktemp -d)

# Function to replace tokens in a file based on variables from YAML
replace_tokens() {
    local file=$1
    echo "Processing $file"

    # Extract all the variable names from the file
    local vars=$(grep -o "${PREFIX}[a-zA-Z0-9_]*${SUFFIX}" "$file" | sed "s/${PREFIX}\(.*\)${SUFFIX}/\1/" | sort -u)

    # Replace each variable in the file with its value from the YAML file
    for var in $vars; do
        local value=$(yq e ".variables[] | select(.name == \"$var\") | .value" "$YAML_FILE")
        # Ensure the value is not empty before replacing
        if [ -n "$value" ]; then
            echo "Replacing ${PREFIX}${var}${SUFFIX} with ${value} in $file"
            sed -i.bak -e "s/${PREFIX}${var}${SUFFIX}/${value}/g" "$file"
        else
            echo "Warning: No value found for variable $var"
        fi
    done

    # Remove backup file created by sed
    rm "${file}.bak"
}

# Function to check if a resource group exists
check_resource_group_exists() {
    local resource_group=$1
    if az group show --name "$resource_group" &>/dev/null; then
        echo "Resource group $resource_group exists."
        return 0
    else
        echo "Resource group $resource_group does not exist."
        return 1
    fi
}

# Function to create the storage container if it doesn't exist
create_container_if_not_exists() {
    local resource_group=$1
    local storage_account=$2
    local container_name=$3

    # Check if the container exists
    if ! az storage container show --name "$container_name" --account-name "$storage_account" &>/dev/null; then
        echo "Creating container $container_name in storage account $storage_account"
        az storage container create --name "$container_name" --account-name "$storage_account" --resource-group "$resource_group"
    else
        echo "Container $container_name already exists in storage account $storage_account"
    fi
}

# Read the pipeline file to get the list of resources and their flags
resources=$(yq e '.resources[] | select(.plan == true or .apply == true) | .name' "$PIPELINE_FILE")

# Get global variables from the YAML file
devops_rg=$(yq e '.variables[] | select(.name == "devops_rg") | .value' "$YAML_FILE")
devops_storage_account=$(yq e '.variables[] | select(.name == "devops_storage_account") | .value' "$YAML_FILE")
app_acronym=$(yq e '.variables[] | select(.name == "app_acronym") | .value' "$YAML_FILE")

# Create the container if it doesn't exist
create_container_if_not_exists "$devops_rg" "$devops_storage_account" "$app_acronym"

# Function to deploy a resource
deploy_resource() {
    local resource=$1
    local plan=$2
    local apply=$3

    # Corresponding .tf file and .auto.tfvars file
    tf_file="tf-code/$resource.tf"
    var_file="tf-configuration/var-$resource.auto.tfvars"

    # Check if the files exist
    if [ ! -f "$tf_file" ]; then
        echo "Warning: $tf_file does not exist. Skipping $resource."
        return 1
    fi

    if [ ! -f "$var_file" ]; then
        echo "Warning: $var_file does not exist. Skipping $resource."
        return 1
    fi

    # Create a temporary subdirectory for each resource
    tmp_subdir="$TMP_DIR/$resource"
    mkdir -p "$tmp_subdir"

    # Copy the .tf and .auto.tfvars files to the temporary subdirectory
    cp "$tf_file" "$tmp_subdir/"
    cp "$var_file" "$tmp_subdir/"

    # Replace tokens in the copied files
    replace_tokens "$tmp_subdir/$(basename "$tf_file")"
    replace_tokens "$tmp_subdir/$(basename "$var_file")"

    echo "Temporary files for $resource created at: $tmp_subdir"

    # Add backend configuration to the .tf file using literal values
    cat <<EOF >> "$tmp_subdir/backend.tf"
terraform {
  backend "azurerm" {
    resource_group_name   = "$devops_rg"
    storage_account_name  = "$devops_storage_account"
    container_name        = "$app_acronym"
    key                   = "${resource}.terraform.tfstate"
  }
}
EOF

    # Run terraform init in the temporary directory
    pushd "$tmp_subdir" > /dev/null
    terraform init

    # Run terraform plan if the plan flag is true
    if [ "$plan" == "true" ]; then
        terraform plan -out=tfplan
        echo "Terraform plan executed for $resource and stored in: $tmp_subdir"
    fi

    # Run terraform apply if the apply flag is true
    if [ "$apply" == "true" ]; then
        terraform apply -auto-approve tfplan
        echo "Terraform apply executed for $resource in: $tmp_subdir"
    fi

    popd > /dev/null
    return 0
}

# Track deployed resources to manage dependencies
declare -a deployed_resources

# Check if resource group already exists
if check_resource_group_exists "$devops_rg"; then
    deployed_resources["resourcegroup"]="true"
fi

# Iterate through the resources to be processed
for resource in $resources; do
    plan=$(yq e ".resources[] | select(.name == \"$resource\") | .plan" "$PIPELINE_FILE")
    apply=$(yq e ".resources[] | select(.name == \"$resource\") | .apply" "$PIPELINE_FILE")
    depends_on=$(yq e ".resources[] | select(.name == \"$resource\") | .depends_on[]" "$PIPELINE_FILE")

    # Check dependencies
    for dep in $depends_on; do
        if [ "${deployed_resources[$dep]}" != "true" ]; then
            echo "Skipping $resource until dependency $dep is deployed."
            continue 2
        fi
    done

    # Deploy the resource
    if deploy_resource "$resource" "$plan" "$apply"; then
        deployed_resources[$resource]="true"
    else
        echo "Failed to deploy $resource."
        exit 1
    fi
done

echo "Replacement and Terraform operations complete."