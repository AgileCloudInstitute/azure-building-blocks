#Copyright 2021 Green River IT (GreenRiverIT.com) as described in LICENSE.txt distributed with this project on GitHub.
#Start at https://github.com/AgileCloudInstitute?tab=repositories

module "net-found-admin-vaults" {
  source = "..\\..\\..\\modules\\net-found-admin-vaults"

  subscriptionId       = var.subscriptionId
  tenantId             = var.tenantId
  clientId             = var.clientId
  clientSecret         = var.clientSecret
  resourceGroupName    = var.resourceGroupName
  resourceGroupRegion  = var.resourceGroupRegion

}

##Input variables.  The client referred to is an App Registration.
variable "subscriptionId" { }
variable "tenantId" { }
variable "clientId" { }
variable "clientSecret" { }
variable "resourceGroupName" { }
variable "resourceGroupRegion" { }

##Output variables
output "pipes_resource_group_name" { value = module.net-found-admin-vaults.pipes_resource_group_name }
output "pipes_resource_group_region" { value = module.net-found-admin-vaults.pipes_resource_group_region }
output "storageAccountDiagName" { value = module.net-found-admin-vaults.storageAccountDiagName }
output "subscription_name" { value = module.net-found-admin-vaults.subscription_name }
output "subscription_id" { value = module.net-found-admin-vaults.subscription_id }
output "tenant_id" { value = module.net-found-admin-vaults.tenant_id }
output "admin_ip_body" { value = module.net-found-admin-vaults.admin_ip_body }
output "admin_cider" { value = module.net-found-admin-vaults.admin_cider }
output "vnetName" { value = module.net-found-admin-vaults.vnetName }
