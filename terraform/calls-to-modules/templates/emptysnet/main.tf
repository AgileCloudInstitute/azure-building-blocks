#Copyright 2021 Green River IT (GreenRiverIT.com) as described in LICENSE.txt distributed with this project on GitHub.
#Start at https://github.com/AgileCloudInstitute?tab=repositories

module "emptysnet" {
  source = "..\\..\\..\\modules\\emptysnet"

  subscriptionId                     = var.subscriptionId
  tenantId                           = var.tenantId
  clientId                           = var.clientId
  clientSecret                       = var.clientSecret
  resourceGroupName                  = var.resourceGroupName
  vnetName                           = var.vnetName
  cidrSubnet                         = var.cidrSubnet
  adminUser                          = var.adminUser
  adminPwd                           = var.adminPwd
  storageAccountDiagName             = var.storageAccountDiagName
  imageName                          = var.imageName
  cloudInit                          = var.cloudInit
#  vaultName                          = var.vaultName
#  gitUser                            = var.gitUser
#  gitPwd                             = var.gitPwd

}


###Input variables
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

output "image_id" { value = module.emptysnet.image_id }  

terraform {
  backend "azurerm" { }
}
