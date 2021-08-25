#Copyright 2021 Green River IT (GreenRiverIT.com) as described in LICENSE.txt distributed with this project on GitHub.
#Start at https://github.com/AgileCloudInstitute?tab=repositories

variable "azdoOrgPAT" { }  
variable "azdoOrgServiceURL" { }  
variable "repoName" { }  
variable "buildName" { }
variable "projectName" { }

data "azuredevops_project" "p" { name = var.projectName }

output "azuredevops_project_id" { value = data.azuredevops_project.p.id }
output "azuredevops_build_definition_id" { value = azuredevops_build_definition.build.id }
output "azuredevops_git_repository_name" { value = azuredevops_git_repository.repository.name }