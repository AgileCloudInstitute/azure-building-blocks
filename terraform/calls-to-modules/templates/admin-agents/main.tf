#Copyright 2024 Agile Cloud Institute, Inc.  (AgileCloudInstitute.io) as described in LICENSE.txt distributed with this project on GitHub.
#Start at https://github.com/AgileCloudInstitute?tab=repositories

module "ad-admin" {
  source = "..\\..\\..\\modules\\admin-agents"

  subscriptionId       = var.subscriptionId
  tenantId             = var.tenantId
  clientId             = var.clientId
  clientSecret         = var.clientSecret
  instanceName         = var.instanceName
#  resourceGroupName    = var.resourceGroupName
#  resourceGroupRegion  = var.resourceGroupRegion
#  keySourceFile        = var.keySourceFile
#  file_secret_name     = var.file_secret_name

}

##Input variables.  The client referred to is an App Registration.
variable "subscriptionId" { }
variable "tenantId" { }
variable "clientId" { }
variable "clientSecret" { }
variable "instanceName" { }
#variable "resourceGroupName" { }
#variable "resourceGroupRegion" { }
#variable "keySourceFile" { }
#variable "file_secret_name" { }

output "application_id" { value = module.ad-admin.application_id }
output "appId" { value = module.ad-admin.appId }
#.The following 3 are a test on 4/18/2024 to be deleted later.
#output "spPwd" { value = module.ad-admin.spPwd }
#output "application_objId" { value = module.ad-admin.application_objId }
#output "spObjectId" { value = module.ad-admin.spObjectId }

terraform {
  backend "azurerm" { }
}
