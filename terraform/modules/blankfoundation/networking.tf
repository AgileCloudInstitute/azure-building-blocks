#Copyright 2024 Agile Cloud Institute, Inc.  (AgileCloudInstitute.io) as described in LICENSE.txt distributed with this project on GitHub.
#Start at https://github.com/AgileCloudInstitute?tab=repositories

resource "azurerm_virtual_network" "pipelines" {
  name                = "pipelineVirtnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.pipelines.location
  resource_group_name = azurerm_resource_group.pipelines.name
}
