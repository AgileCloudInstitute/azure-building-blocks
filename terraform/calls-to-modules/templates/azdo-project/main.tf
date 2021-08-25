#Copyright 2021 Green River IT (GreenRiverIT.com) as described in LICENSE.txt distributed with this project on GitHub.
#Start at https://github.com/AgileCloudInstitute?tab=repositories

module "azdo-project" {
  source = "..\\..\\..\\modules\\azdo-project"

  subscriptionName                     = var.subscriptionName
  subscriptionId                       = var.subscriptionId
  tenantId                             = var.tenantId
  clientName                           = var.clientName
  clientId                             = var.clientId
  clientSecret                         = var.clientSecret
  azdoOrgPAT                           = var.azdoOrgPAT
  azdoOrgServiceURL                    = var.azdoOrgServiceURL
  projectName                          = var.projectName
}

variable "subscriptionName" { }  
variable "subscriptionId" { }  
variable "tenantId" { }  
#The client referred to is an App Registration.  
variable "clientName" { }  
variable "clientId" { }  
variable "clientSecret" { }  
variable "azdoOrgPAT" { }  
variable "azdoOrgServiceURL" { }  
variable "projectName" { } 

output "azuredevops_service_connection_id" { value = module.azdo-project.azuredevops_service_connection_id }
output "azuredevops_project_id" { value = module.azdo-project.azuredevops_project_id }
