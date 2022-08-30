#Copyright 2022 Green River IT (GreenRiverIT.com) as described in LICENSE.txt distributed with this project on GitHub.
#Start at https://github.com/AgileCloudInstitute?tab=repositories

module "blankfoundation" {
  source = "..\\..\\..\\modules\\blankfoundation"

  subscriptionId                = var.subscriptionId
  tenantId                      = var.tenantId
  clientId                      = var.clientId
  clientSecret                  = var.clientSecret
  resourceGroupRegion           = var.resourceGroupRegion
  resourceGroupName             = var.resourceGroupName
  vpcCIDR                       = var.vpcCIDR
  secondString                  = var.secondString
  clientName                    = var.clientName
  subName                       = var.subName
  labrador                      = var.labrador
  tName                         = var.tName
  networkName                   = var.networkName
  owner                         = var.owner
  makePath                      = var.makePath
  now                           = var.now
  addOrgTest                    = var.addOrgTest

}

##Input variables.  The client referred to is an App Registration.
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

##Output variables
output "first_output_var" { value = module.blankfoundation.first_output_var }
output "second_output_var" { value = module.blankfoundation.second_output_var }
output "storageAccountDiagName" { value = module.blankfoundation.storageAccountDiagName }
output "vnetName" { value = module.blankfoundation.vnetName }
 
terraform {
  backend "azurerm" { }
}
