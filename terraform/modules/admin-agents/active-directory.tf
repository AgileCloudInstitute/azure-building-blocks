#Copyright 2022 Green River IT (GreenRiverIT.com) as described in LICENSE.txt distributed with this project on GitHub.
#Start at https://github.com/AgileCloudInstitute?tab=repositories

variable "subscriptionId" { }
variable "tenantId" { }
variable "clientId" { }
variable "clientSecret" { }
variable "instanceName" { }
#variable "resourceGroupName" { }
#variable "resourceGroupRegion" { }
#variable "keySourceFile" { }
#variable "file_secret_name" { }

## Workstation External IP. Override with variable or hardcoded value if necessary.
data "http" "admin-external-ip" { url = "https://api.ipify.org" }
locals { admin-external-cidr = "${chomp(data.http.admin-external-ip.body)}/32" }

output "application_id" { value = azuread_application.appRegistration.application_id }
output "appId" { value = azuread_service_principal.appRegistrationSP.application_id }
#.The following 3 are a test on 4/18/2022 to be deleted later.
#output "spPwd" { value = azuread_service_principal_password.appRegistrationSP_pwd.value }
#output "application_objId" { value = azuread_application.appRegistration.object_id }
#output "spObjectId" { value = azuread_service_principal.appRegistrationSP.object_id }

###############################################################################################
### Providers 
###############################################################################################

#Configure terraform
terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.6.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.79.1"
    }
  }
}
  
# Configure the Microsoft Azure Active Directory Provider
provider "azuread" {
  tenant_id       = var.tenantId
  client_id       = var.clientId
  client_secret   = var.clientSecret
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
    subscription_id = var.subscriptionId
    client_id       = var.clientId
    client_secret   = var.clientSecret
    tenant_id       = var.tenantId
    # An empty features {} block is necessary at minimum.  It can be filled with sub-blocks for specific features.
    features { 
      key_vault {
        purge_soft_delete_on_destroy = true
        recover_soft_deleted_key_vaults = true
      }
    }
}

################################################################################################
### Identity Resources
################################################################################################

# Create an application
resource "azuread_application" "appRegistration" {
  display_name = var.instanceName
  app_role {
    allowed_member_types = ["User", "Application"]
    description          = "Admins can manage roles and perform all task actions"
    display_name         = "Admin"
    enabled              = true
    id                   = "1b19509b-32b1-4e9f-b71d-4992aa991967"
    value                = "admin"
  }
}

# Create a service principal
resource "azuread_service_principal" "appRegistrationSP" {
  application_id = azuread_application.appRegistration.application_id
}

resource "azuread_service_principal_password" "appRegistrationSP_pwd" {
  service_principal_id = azuread_service_principal.appRegistrationSP.id
  depends_on = [ azuread_service_principal.appRegistrationSP ]
}

data "azurerm_subscription" "thisSubscription" {
  subscription_id = var.subscriptionId
}

resource "azurerm_role_assignment" "appRegistrationSP_role_assignment" {
  scope                = data.azurerm_subscription.thisSubscription.id
  #role_definition_name = "Contributor"
  role_definition_name = "Owner"
  principal_id         = azuread_service_principal.appRegistrationSP.id
  depends_on = [ azuread_service_principal_password.appRegistrationSP_pwd ]
}

resource "azurerm_role_assignment" "appRegistrationSP_role_assignment_vault" {
  scope                = data.azurerm_subscription.thisSubscription.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = azuread_service_principal.appRegistrationSP.id
  depends_on = [ azuread_service_principal_password.appRegistrationSP_pwd ]
}

################################################################################################
### Key Vault Resources
################################################################################################

##Now create a key vault as an experiment.  The following will need to be matured later:
#resource "azurerm_key_vault" "adminVault" {
#  name                        = var.instanceName
#  location                    = var.resourceGroupRegion
#  resource_group_name         = var.resourceGroupName
#  enabled_for_disk_encryption = true
#  tenant_id                   = var.tenantId
#  soft_delete_retention_days  = 7
#  purge_protection_enabled    = false
#  sku_name = "standard"

#  network_acls {
#    ##CHANGE THE FOLLOWING LINE TO "Deny" FOR PRODUCTION.
#    default_action = "Allow"
#    bypass         = "AzureServices"
#    ip_rules       = [local.admin-external-cidr]
#    #commenting the next line until the order of creation of resources has been spelled out
##    virtual_network_subnet_ids = [azurerm_subnet.pipelines.id]
#  }

#  tags = { environment = "Testing" }

#}

##Use this data source to access the configuration of the azurerm provider, which you configured above:
##MAKE WORK ITEM TO CHECK IF THE OBJECT ID FROM THIS data.azurerm_client_config CAN BE BROUGHT IN USING AN INPUT VARIABLE TO AVOID CONFLICTS WITH THE OTHER INPUT VARIABLES.
#data "azurerm_client_config" "current" {}

#resource "azurerm_key_vault_access_policy" "userCreatedSP" {
#  key_vault_id = azurerm_key_vault.adminVault.id
#  tenant_id = var.tenantId
#  object_id = var.clientId
#  certificate_permissions = [ "create", "delete", "deleteissuers", "get", "getissuers", "import", "list", "listissuers", "managecontacts", "manageissuers", "setissuers", "update", ]
#  key_permissions = [ "backup", "create", "decrypt", "delete", "encrypt", "get", "import", "list", "purge", "recover", "restore", "sign", "unwrapKey", "update", "verify", "wrapKey", ]
#  secret_permissions = [ "backup", "delete", "get", "list", "purge", "recover", "restore", "set", ]
#  storage_permissions = [ "get", ]
#  depends_on = [ azurerm_key_vault.adminVault ]
#}

#resource "azurerm_key_vault_access_policy" "userCreatedSP2" {
#  key_vault_id = azurerm_key_vault.adminVault.id
#  tenant_id = var.tenantId
#  object_id = data.azurerm_client_config.current.object_id
#  certificate_permissions = [ "create", "delete", "deleteissuers", "get", "getissuers", "import", "list", "listissuers", "managecontacts", "manageissuers", "setissuers", "update", ]
#  key_permissions = [ "backup", "create", "decrypt", "delete", "encrypt", "get", "import", "list", "purge", "recover", "restore", "sign", "unwrapKey", "update", "verify", "wrapKey", ]
#  secret_permissions = [ "backup", "delete", "get", "list", "purge", "recover", "restore", "set", ]
#  storage_permissions = [ "get", ]
#  depends_on = [ azurerm_key_vault.adminVault ]
#}

###Now create secret and attach to the new key vault.
#resource "azurerm_key_vault_secret" "appRegistrationPassword" {
#  name         = "app-registration-password"
#  value        = azuread_service_principal_password.appRegistrationSP_pwd.value
#  key_vault_id = azurerm_key_vault.adminVault.id
#  tags = { environment = "Testing" }
#  depends_on = [
#    azurerm_key_vault_access_policy.userCreatedSP, 
#    azurerm_key_vault_access_policy.userCreatedSP2, 
#    azurerm_key_vault.adminVault
#  ]
#}

#resource "azurerm_key_vault_secret" "keysFile" {
#  name         = var.file_secret_name
#  value        = filebase64(var.keySourceFile) 
#  key_vault_id = azurerm_key_vault.adminVault.id
#  tags = { environment = "Testing" }
#  depends_on = [azurerm_key_vault_access_policy.userCreatedSP, azurerm_key_vault_access_policy.userCreatedSP2]
#}
