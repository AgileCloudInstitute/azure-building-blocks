#Copyright 2021 Green River IT (GreenRiverIT.com) as described in LICENSE.txt distributed with this project on GitHub.
#Start at https://github.com/AgileCloudInstitute?tab=repositories

provider "azuredevops" {
  personal_access_token = var.azdoOrgPAT
  org_service_url = var.azdoOrgServiceURL
}

terraform {
  required_providers {
    azuredevops = {
      source = "microsoft/azuredevops"
    }
  }
}
