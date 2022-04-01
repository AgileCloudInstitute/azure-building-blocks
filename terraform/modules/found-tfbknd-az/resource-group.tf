#Copyright 2021 Green River IT (GreenRiverIT.com) as described in LICENSE.txt distributed with this project on GitHub.
#Start at https://github.com/AgileCloudInstitute?tab=repositories

resource "azurerm_resource_group" "backends" {
  name     = var.resourceGroupName
  location = var.pipeAzureRegion
}