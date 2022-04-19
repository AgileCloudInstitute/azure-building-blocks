#Copyright 2021 Green River IT (GreenRiverIT.com) as described in LICENSE.txt distributed with this project on GitHub.
#Start at https://github.com/AgileCloudInstitute?tab=repositories

module "foundation" {
  source = "..\\..\\..\\modules\\foundation"

  subscriptionId                = var.subscriptionId
  tenantId                      = var.tenantId
  clientId                      = var.clientId
  clientSecret                  = var.clientSecret
  resourceGroupName             = var.resourceGroupName
  resourceGroupRegion           = var.resourceGroupRegion
  cidrSubnetPacker              = var.cidrSubnetPacker
  file_secret_name              = var.file_secret_name
  keySourceFile                 = var.keySourceFile
  vaultName                     = var.vaultName

}

##Input variables.  The client referred to is an App Registration.
variable "subscriptionId" { }
variable "tenantId" { }
variable "clientId" { }
variable "clientSecret" { }
variable "resourceGroupName" { }
variable "resourceGroupRegion" { }
variable "cidrSubnetPacker" { }
#
variable "file_secret_name" { }
variable "keySourceFile" { }
variable "vaultName" { }

##Output variables
output "pipes_resource_group_name" { value = module.foundation.pipes_resource_group_name }
output "pipes_resource_group_region" { value = module.foundation.pipes_resource_group_region }
output "storageAccountDiagName" { value = module.foundation.storageAccountDiagName }
output "subscription_name" { value = module.foundation.subscription_name }
output "subscription_id" { value = module.foundation.subscription_id }
output "tenant_id" { value = module.foundation.tenant_id }
output "admin_ip_body" { value = module.foundation.admin_ip_body }
output "admin_cider" { value = module.foundation.admin_cider }
output "vnetName" { value = module.foundation.vnetName }

terraform {
  backend "azurerm" { }
}
