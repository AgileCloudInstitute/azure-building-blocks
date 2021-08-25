#Copyright 2021 Green River IT (GreenRiverIT.com) as described in LICENSE.txt distributed with this project on GitHub.
#Start at https://github.com/AgileCloudInstitute?tab=repositories

module "snet-packer" {
  source = "..\\..\\..\\modules\\snet-packer"

  subscriptionId                     = var.subscriptionId
  tenantId                           = var.tenantId
  clientId                           = var.clientId
  clientSecret                       = var.clientSecret
  resourceGroupName                  = var.resourceGroupName
  vnetName                           = var.vnetName 
  cidrSubnet                         = var.cidrSubnet

}

##Input variables
variable "subscriptionId" { }
variable "tenantId" { }
#The client referred to is an App Registration.
variable "clientId" { }
variable "clientSecret" { }
variable "resourceGroupName" { }
variable "vnetName" { }
variable "cidrSubnet" { }
