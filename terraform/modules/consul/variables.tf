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
variable "resourceGroupLocation" { }
variable "vnetName" { }
variable "cidrSubnet" { }
variable "imageName" { }
variable "adminUser" { }
variable "adminPwd" { }
variable "vaultName" { }
variable "cloudInit" { }
variable "storageAccountDiagName" { }



# Workstation External IP. Override with variable or hardcoded value if necessary.
data "http" "admin-external-ip" { url = "http://ipv4.icanhazip.com" }
locals { 
  admin-external-cidr = "${chomp(data.http.admin-external-ip.body)}/32"
  admin-external-ip = chomp(data.http.admin-external-ip.body) 
}

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


##Define the output variables
output "admin_ip_body" { value = local.admin-external-ip }
output "admin_cider" { value = local.admin-external-cidr }