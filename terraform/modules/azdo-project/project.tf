#Copyright 2021 Green River IT (GreenRiverIT.com) as described in LICENSE.txt distributed with this project on GitHub.
#Start at https://github.com/AgileCloudInstitute?tab=repositories


resource "azuredevops_project" "project" {
  name       = var.projectName
  visibility         = "private"
  version_control    = "Git"
  work_item_template = "Agile"
}

resource "azuredevops_serviceendpoint_azurerm" "endpointazure" {  
  project_id            = azuredevops_project.project.id  
  service_endpoint_name = var.clientName  
  description = "Managed by Terraform" 
  credentials {  
    serviceprincipalid  = var.clientId  
    serviceprincipalkey = var.clientSecret  
  }  
  azurerm_spn_tenantid      = var.tenantId  
  azurerm_subscription_id   = var.subscriptionId  
  azurerm_subscription_name = var.subscriptionName  
}  
