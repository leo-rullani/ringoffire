resource_group_name = "[__resource_group_name__]"
location            = "[__location__]"
adf_name            = "[__adf_name__]"

# Git part
account_name    = "[__account_name__]"
branch_name     = "[__branch_name__]"
source_control  = "https://[__source_control__]/[__account_name__]/[__repository_name__]"
repository_name = "[__repository_name__]"

key_vault_id = "/subscriptions/[__azure_subscription__]/resourceGroups/[__resource_group_name__]/providers/Microsoft.KeyVault/vaults/[__keyvault_name__]"

adf_roles = {
  adls_role = {
    scope = "/subscriptions/[__azure_subscription__]/resourceGroups/[__resource_group_name__]/providers/Microsoft.Storage/storageAccounts/[__storage_account_name__]"
    role  = "Storage Blob Data Contributor"
  }
}

tags = {
  env = "[__env__]"
}