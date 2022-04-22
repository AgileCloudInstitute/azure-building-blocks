#Copyright 2021 Green River IT (GreenRiverIT.com) as described in LICENSE.txt distributed with this project on GitHub.
#Start at https://github.com/AgileCloudInstitute?tab=repositories

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

#Use this data source to access the configuration of the azurerm provider, which you configured using the above variables:
data "azurerm_client_config" "current" {}

output "azuredevops_service_connection_id" { value = azuredevops_serviceendpoint_azurerm.endpointazure.id }
output "azuredevops_project_id" { value = azuredevops_project.project.id }


 
variable "repoName" { }  
#variable "buildName" { }


#output "azuredevops_build_definition_id" { value = azuredevops_build_definition.build.id }
output "azuredevops_git_repository_name" { value = azuredevops_git_repository.repository.name }
