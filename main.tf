######################################################################################
# Terraform supermodule for the Terraform platform engineering for Azure.
# Recommended module from Microsoft.
# Github Link : https://github.com/aztfmod/terraform-azurerm-caf
# But this supermodule is not fully compatible with our requirement in some places
# we used individual resource blocks.
######################################################################################

module "caf" {
  source  = "aztfmod/caf/azurerm"
  version = "5.7.0"

  providers = {
    azurerm.vhub = azurerm
  }

  global_settings = var.global_settings
  resource_groups = var.resource_groups
  #keyvaults       = local.keyvaults

  # To create peerings, adding public ip address and adding private vnet links.
  networking = {
    public_ip_addresses    = var.public_ip_addresses
    #vnet_peerings_v1       = local.vnet_peerings_v1
    #private_dns_vnet_links = local.private_dns_vnet_links_v1
    #application_gateway_applications = var.application_gateway_applications
    #application_gateways = var.application_gateways
  }

  # To deploy Bastion workload.
#   compute = {
#     bastion_hosts = local.bastion_hosts
#   }

  # To create vnet links in private dns zone.
  remote_objects = {
    vnets           = var.vnets
    #private_dns     = local.private_dns
    #resource_groups = local.resource_groups_remote
  }
}
