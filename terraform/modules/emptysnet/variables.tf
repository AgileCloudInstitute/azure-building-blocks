#Copyright 2021 Green River IT (GreenRiverIT.com) as described in LICENSE.txt distributed with this project on GitHub.
#Start at https://github.com/AgileCloudInstitute?tab=repositories

####################################################################################################################
####Define the input variables:  
####################################################################################################################
variable "subscriptionId" { }
variable "tenantId" { }
##The client referred to is an App Registration.
variable "clientId" { }
variable "clientSecret" { }
variable "resourceGroupName" { }
variable "vnetName" { }
variable "cidrSubnet" { }
variable "adminUser" { }
variable "adminPwd" { }
variable "storageAccountDiagName" { }
variable "imageName" { }
variable "cloudInit" { }


## Workstation External IP. Override with variable or hardcoded value if necessary.
data "http" "admin-external-ip" { url = "https://api.ipify.org" }

locals { admin-external-cidr = "${chomp(data.http.admin-external-ip.body)}/32" }


###Manually imported things need placeholders as follows:

data "azurerm_resource_group" "pipeline-resources" {
  name = var.resourceGroupName
}

data "azurerm_storage_account" "mystorageaccount" {
  name                = var.storageAccountDiagName
  resource_group_name = var.resourceGroupName
}

data "azurerm_virtual_network" "vnetTarget" {
  name                = var.vnetName
  resource_group_name = data.azurerm_resource_group.pipeline-resources.name
}

output "image_id" { value = data.azurerm_image.search.id }  