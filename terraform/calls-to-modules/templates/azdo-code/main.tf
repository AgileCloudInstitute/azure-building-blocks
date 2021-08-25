#Copyright 2021 Green River IT (GreenRiverIT.com) as described in LICENSE.txt distributed with this project on GitHub.
#Start at https://github.com/AgileCloudInstitute?tab=repositories

module "azdo-code" {
  source = "..\\..\\..\\modules\\azdo-code"

  azdoOrgPAT                           = var.azdoOrgPAT
  azdoOrgServiceURL                    = var.azdoOrgServiceURL
  repoName                             = var.repoName
  buildName                            = var.buildName
  projectName                          = var.projectName
}

variable "azdoOrgPAT" { }  
variable "azdoOrgServiceURL" { }  
variable "repoName" { } 
variable "buildName" { }
variable "projectName" { }

output "azuredevops_project_id" { value = module.azdo-code.azuredevops_project_id }
output "azuredevops_build_definition_id" { value = module.azdo-code.azuredevops_build_definition_id }
output "azuredevops_git_repository_name" { value = module.azdo-code.azuredevops_git_repository_name }
