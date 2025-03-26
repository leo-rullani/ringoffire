resource_group_name = "[__resource_group_name__]"
location            = "[__location__]"

private_endpoints = {
  dfs_endpoint = {
    name                           = "[__storage_account_name__]-pe"
    subnet_id                      = "/subscriptions/[__azure_subscription__]/resourceGroups/[__resource_group_name__]/providers/Microsoft.Network/virtualNetworks/[__vnet_name__]/subnets/[__pe_subnet__]"
    private_connection_resource_id = "/subscriptions/[__azure_subscription__]/resourceGroups/[__resource_group_name__]/providers/Microsoft.Storage/storageAccounts/[__storage_account_name__]"
    groups_ids                     = ["dfs"]
    approval_require               = false
    approval_message               = ""
    dns_zone_names                 = ["privatelink.dfs.core.windows.net"]
    dns_zone_group_name            = "dfs"
    private_dns_zone_ids           = ["/subscriptions/[__azure_subscription__]/resourceGroups/[__resource_group_name__]/providers/Microsoft.Network/privateDnsZones/privatelink.dfs.core.windows.net"]
  }
}

tags = {
  env = "[__env__]"
}