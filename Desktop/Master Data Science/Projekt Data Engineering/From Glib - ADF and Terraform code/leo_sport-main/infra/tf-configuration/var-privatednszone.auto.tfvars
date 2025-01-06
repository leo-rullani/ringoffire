resource_group_name = "[__resource_group_name__]"
location            = "[__location__]"


private_dns_zones = {
  zone1 = {
    dns_zone_name = "privatelink.dfs.core.windows.net"
  }
}

private_dns_zone_links = {
  link1 = {
    name         = "vnet-link"
    dns_zone_key = "zone1"
    vnet_id      = "/subscriptions/[__azure_subscription__]/resourceGroups/[__resource_group_name__]/providers/Microsoft.Network/virtualNetworks/[__vnet_name__]"
  }
}

tags = {
  env = "[__env__]"
}