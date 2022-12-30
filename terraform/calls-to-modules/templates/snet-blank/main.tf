#Copyright 2022 Green River IT (GreenRiverIT.com) as described in LICENSE.txt distributed with this project on GitHub.
#Start at https://github.com/AgileCloudInstitute?tab=repositories

module "snet-blank" {
  source = "..\\..\\..\\modules\\snet-blank"

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

  firstSharedVariable                = var.firstSharedVariable
  imageId                            = var.imageId
  KeyName                            = var.KeyName
  InstanceType                       = var.InstanceType
  clientName                         = var.clientName
  canary                             = var.canary
  lab                                = var.lab
  oneVar                             = var.oneVar
  twoInstanceVar                     = var.twoInstanceVar
  networkName                        = var.networkName
  environ                            = var.environ
  vpcCIDR                            = var.vpcCIDR
  alternate                          = var.alternate
  first_output_var                   = var.first_output_var
  secondVar                          = var.secondVar
  makePath                           = var.makePath
  now                                = var.now
  addOrgTest                         = var.addOrgTest

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

variable "firstSharedVariable" { }
variable "imageId" { }
variable "KeyName" { }
variable "InstanceType" { }
variable "clientName" { }
variable "canary" { }
variable "lab" { }
variable "oneVar" { }
variable "twoInstanceVar" { }
variable "networkName" { }
variable "environ" { }
variable "vpcCIDR" { }
variable "alternate" { }
variable "first_output_var" { }
variable "secondVar" { }
variable "makePath" { }
variable "now" { }
variable "addOrgTest" { }


output "image_id" { value = module.snet-blank.image_id }  
#output "vaultName" { value = module.snet-blank.vaultName }  

terraform {
  backend "azurerm" { }
}
