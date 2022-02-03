#Copyright 2021 Green River IT (GreenRiverIT.com) as described in LICENSE.txt distributed with this project on GitHub.
#Start at https://github.com/AgileCloudInstitute?tab=repositories

module "ad-admin" {
  source = "..\\..\\..\\modules\\ad-admin"

  subscriptionId       = var.subscriptionId
  tenantId             = var.tenantId
  clientId             = var.clientId
  clientSecret         = var.clientSecret
  instanceName         = var.instanceName
  resourceGroupName    = var.resourceGroupName
  resourceGroupRegion  = var.resourceGroupRegion

}

##Input variables.  The client referred to is an App Registration.
variable "subscriptionId" { }
variable "tenantId" { }
variable "clientId" { }
variable "clientSecret" { }
variable "instanceName" { }
variable "resourceGroupName" { }
variable "resourceGroupRegion" { }

output "application_id" { value = module.ad-admin.application_id }
output "appId" { value = module.ad-admin.appId }

terraform {
  backend "azurerm" { }
}

