#Copyright 2024 Agile Cloud Institute, Inc.  (AgileCloudInstitute.io) as described in LICENSE.txt distributed with this project on GitHub.
#Start at https://github.com/AgileCloudInstitute?tab=repositories

resource "azurerm_resource_group" "pipelines" {
  name     = var.resourceGroupName
  location = var.resourceGroupRegion
}
