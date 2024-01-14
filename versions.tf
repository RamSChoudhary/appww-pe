terraform {
  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "1.6.0"
    }
  }
backend "azurerm" {
    resource_group_name  = "rg-lz-tfstate-eastus-001"
    storage_account_name = "strglzeastus003"
    container_name       = "terraform"
    key                  = "connecitivity.tfstate"
    use_oidc             = true
    client_id       = "2c5a8bc7-bc9c-4e30-9cc5-d7c765f0e9f1"
    subscription_id = "a20c6610-8802-4de7-91ff-dcd95bcbb16d"
    tenant_id       = "6247d758-84d5-49c9-b680-d24ea85bb764"
  }
}

provider "azurerm" {
  features {}
}

################################
# All these subscriptions ids are added in secrets in this repo.
# Used reusable workflow and in it reading secrets from repo. 
################################
# provider "azurerm" {
#   features {}
#   alias           = "management"
#   subscription_id = var.managementsubid
# }

# provider "azurerm" {
#   features {}
#   alias           = "security"
#   subscription_id = var.securitysubid
# }

# provider "azurerm" {
#   features {}
#   alias           = "identity"
#   subscription_id = var.identitysubid
# }


provider "azuread" {
}

provider "azapi" {
}
