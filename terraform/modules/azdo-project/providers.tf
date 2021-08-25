#Copyright 2021 Green River IT (GreenRiverIT.com) as described in LICENSE.txt distributed with this project on GitHub.
#Start at https://github.com/AgileCloudInstitute?tab=repositories

# Configure the Microsoft Azure Provider
provider "azurerm" {
    subscription_id = var.subscriptionId
    client_id       = var.clientId
    client_secret   = var.clientSecret
    tenant_id       = var.tenantId

    #The following features block will prevent Azure from retaining the key vault each time you run terraform destroy, provided purge is set to "true".  If remove the key_vault feature, make sure to retain an empty features {} block.
    features { }
}

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
