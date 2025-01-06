resource_group_name = "[__resource_group_name__]"
location            = "[__location__]"
address_space       = ["10.0.0.0/16"]
vnet_name           = "[__vnet_name__]"
nsg_name            = "[__nsg_name__]"

subnets = {
  snet1 = {
    name             = "[__pe_subnet__]"
    address_prefixes = ["10.0.1.0/24"]
    delegation       = []
  },
  snet2 = {
    name             = "[__app_subnet__]"
    address_prefixes = ["10.0.2.0/24"]
    delegation       = []
  },
  snet3 = {
    name             = "[__mysql_subnet__]"
    address_prefixes = ["10.0.3.0/24"]
    delegation = [
      {
        name = "fs"
        service_delegation = [
          {
            name    = "Microsoft.DBforMySQL/flexibleServers"
            actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
          }
        ]
      }
    ]
  }
}
tags = {
  env = "[__env__]"
}




# Example of Subnet with Delegation
# subnets = [
#     {
#         name = "[__xxx__]"
#         address_prefixes = [""]
#         delegation = [
#             {
#                 name = "[__xxx__]"
#                 service_delegation = [
#                     {
#                         name = "[__xxx__]"
#                         actions = [""]
#                     }
#                 ]
#             }
#         ]
#     }
# ]
