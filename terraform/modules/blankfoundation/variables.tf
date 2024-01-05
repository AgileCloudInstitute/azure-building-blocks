#Copyright 2024 Agile Cloud Institute, Inc.  (AgileCloudInstitute.io) as described in LICENSE.txt distributed with this project on GitHub.
#Start at https://github.com/AgileCloudInstitute?tab=repositories

####################################################################################################################
####Define the input variables:  
####################################################################################################################
#The client referred to is an App Registration.

variable "subscriptionId" { }
variable "tenantId" { }
variable "clientId" { }
variable "clientSecret" { }
variable "resourceGroupRegion" { }
variable "resourceGroupName" { }
variable "vpcCIDR" { }
variable "secondString" { }
variable "clientName" { }
variable "subName" { }
variable "labrador" { }
variable "tName" { }
variable "networkName" { }
variable "owner" { }
variable "makePath" { }
variable "now" { }
variable "addOrgTest" { }


##Define the output variables
output "first_output_var" { value = "one-value" }
output "second_output_var" { value = "two-value" }
output "storageAccountDiagName" { value = azurerm_storage_account.mystorageaccount.name }
output "vnetName" { value = azurerm_virtual_network.pipelines.name }
