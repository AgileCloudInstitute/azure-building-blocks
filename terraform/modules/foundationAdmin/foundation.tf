resource "azurerm_resource_group" "admin" {
  name     = var.resourceGroupName
  location = var.resourceGroupRegion
}