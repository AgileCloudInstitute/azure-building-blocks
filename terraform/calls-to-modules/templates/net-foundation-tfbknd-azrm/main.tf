#Copyright 2021 Green River IT (GreenRiverIT.com) as described in LICENSE.txt distributed with this project on GitHub.
#Start at https://github.com/AgileCloudInstitute?tab=repositories

module "net-foundation-tfbknd-azrm" {
  source = "..\\..\\..\\modules\\net-foundation-tfbknd-azrm"

  subscriptionId     = var.subscriptionId
  tenantId           = var.tenantId
  clientId           = var.clientId
  clientSecret       = var.clientSecret
  pipeAzureRegion    = var.pipeAzureRegion

}

##Input variables.  The client referred to is an App Registration.
variable "subscriptionId" { }
variable "tenantId" { }
variable "clientId" { }
variable "clientSecret" { }
variable "pipeAzureRegion" { }

##Output variables
output "pipes_resource_group_name" { value = module.net-foundation-tfbknd-azrm.pipes_resource_group_name }
output "pipes_resource_group_region" { value = module.net-foundation-tfbknd-azrm.pipes_resource_group_region }
output "storageAccountDiagName" { value = module.net-foundation-tfbknd-azrm.storageAccountDiagName }
output "subscription_name" { value = module.net-foundation-tfbknd-azrm.subscription_name }
output "subscription_id" { value = module.net-foundation-tfbknd-azrm.subscription_id }
output "tenant_id" { value = module.net-foundation-tfbknd-azrm.tenant_id }
output "admin_ip_body" { value = module.net-foundation-tfbknd-azrm.admin_ip_body }
output "admin_cider" { value = module.net-foundation-tfbknd-azrm.admin_cider }
output "vnetName" { value = module.net-foundation-tfbknd-azrm.vnetName }
