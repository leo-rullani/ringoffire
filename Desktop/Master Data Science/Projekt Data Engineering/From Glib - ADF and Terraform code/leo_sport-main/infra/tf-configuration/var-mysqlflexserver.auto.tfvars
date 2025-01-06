resource_group_name = "[__resource_group_name__]"
location            = "[__location__]"


vnet_id      = "/subscriptions/[__azure_subscription__]/resourceGroups/[__resource_group_name__]/providers/Microsoft.Network/virtualNetworks/[__vnet_name__]"
subnet_id    = "/subscriptions/[__azure_subscription__]/resourceGroups/[__resource_group_name__]/providers/Microsoft.Network/virtualNetworks/[__vnet_name__]/subnets/[__mysql_subnet__]"
key_vault_id = "/subscriptions/[__azure_subscription__]/resourceGroups/[__resource_group_name__]/providers/Microsoft.KeyVault/vaults/[__keyvault_name__]"


tags = {
  env = "[__env__]"
}
