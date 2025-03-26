#!/bin/bash

# Path to the YAML file containing variable definitions
YAML_FILE="dev-variables.yaml"
TEMP_YAML_FILE="${YAML_FILE}.tmp"

# Function to substitute variables within the YAML file
substitute_variables() {
    local yaml_file=$1
    local temp_file=$2

    # Read all variable names and values into arrays
    local names=()
    local values=()
    local len=$(yq e '.variables | length' "$yaml_file")

    for ((i=0; i<len; i++)); do
        names+=("$(yq e ".variables[$i].name" "$yaml_file")")
        values+=("$(yq e ".variables[$i].value" "$yaml_file")")
    done

    # Substitute variables in values
    local changes=1
    while [ $changes -ne 0 ]; do
        changes=0
        for i in "${!names[@]}"; do
            for j in "${!values[@]}"; do
                if echo "${values[$j]}" | grep -q "\$(${names[$i]})"; then
                    values[$j]=$(echo "${values[$j]}" | sed "s|\$(${names[$i]})|${values[$i]}|g")
                    changes=1
                fi
            done
        done
    done

    # Create a new YAML file with substituted values
    echo "variables:" > "$temp_file"
    for i in "${!names[@]}"; do
        echo "  - name: ${names[$i]}" >> "$temp_file"
        echo "    value: \"${values[$i]}\"" >> "$temp_file"
    done
}

# Substitute variables in a temporary dev-variables.yaml file
substitute_variables "$YAML_FILE" "$TEMP_YAML_FILE"

# Output the resulting temp YAML file
cat "$TEMP_YAML_FILE"

# Run Replace tokem
./replace_tokens.sh $TEMP_YAML_FILE

# Remove temp file
rm $TEMP_YAML_FILE