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
  keyvaults       = var.keyvaults



security = {
    keyvault_certificates = var.keyvault_certificates
}
  # To create peerings, adding public ip address and adding private vnet links.
   networking = {
     public_ip_addresses    = var.public_ip_addresses
     network_security_group_definition = var.network_security_group_definition
#     application_gateway_applications = var.application_gateway_applications
#     application_gateways = var.application_gateways
     vnets           = var.vnets
   }
  

}
