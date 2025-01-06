resource_group_name = "[__resource_group_name__]"
location            = "[__location__]"

storage_account = "[__storage_account_name__]"
storage_containers = {
  cont1 = {
    name                  = "[__container_name__]"
    container_access_type = "private"
  }
}
tags = {
  env = "[__env__]"
}
ip_rules     = ["[__my_ip__]"]
key_vault_id = "/subscriptions/[__azure_subscription__]/resourceGroups/[__resource_group_name__]/providers/Microsoft.KeyVault/vaults/[__keyvault_name__]"