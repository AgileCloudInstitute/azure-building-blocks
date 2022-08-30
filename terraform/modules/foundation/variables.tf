#Copyright 2021 Green River IT (GreenRiverIT.com) as described in LICENSE.txt distributed with this project on GitHub.
#Start at https://github.com/AgileCloudInstitute?tab=repositories

####################################################################################################################
####Define the input variables:  
####################################################################################################################
variable "subscriptionId" { }
variable "tenantId" { }
#The client referred to is an App Registration.
variable "clientId" { }
variable "clientSecret" { }
variable "resourceGroupName" { }
variable "resourceGroupRegion" { }
variable "cidrSubnetPacker" { }
  
variable "file_secret_name" { }
variable "keySourceFile" { }
variable "file_secret_name_two" { }
variable "keySourceFileTwo" { }
variable "vaultName" { }

# Workstation External IP. Override with variable or hardcoded value if necessary.
data "http" "admin-external-ip" { url = "http://ipv4.icanhazip.com" }
locals { 
  admin-external-cidr = "${chomp(data.http.admin-external-ip.body)}/32"
  admin-external-ip = chomp(data.http.admin-external-ip.body) 
} 

##Define the output variables
output "pipes_resource_group_name" { value = azurerm_resource_group.pipelines.name }
output "pipes_resource_group_region" { value = azurerm_resource_group.pipelines.location }
output "storageAccountDiagName" { value = azurerm_storage_account.mystorageaccount.name }

data "azurerm_subscription" "current" {}
output "subscription_name" { value = data.azurerm_subscription.current.display_name }
output "subscription_id" { value = data.azurerm_subscription.current.subscription_id }
output "tenant_id" { value = data.azurerm_subscription.current.tenant_id }
output "admin_ip_body" { value = local.admin-external-ip }
output "admin_cider" { value = local.admin-external-cidr }
output "vnetName" { value = azurerm_virtual_network.pipelines.name }