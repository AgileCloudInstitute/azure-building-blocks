module "foundationAdmin" {
  source = "..\\..\\..\\modules\\foundationAdmin"

  subscriptionId       = var.subscriptionId
  tenantId             = var.tenantId
  clientId             = var.clientId
  clientSecret         = var.clientSecret
  resourceGroupName    = var.resourceGroupName
  resourceGroupRegion  = var.resourceGroupRegion

}

variable "subscriptionId" { }
variable "tenantId" { }
variable "clientId" { }
variable "clientSecret" { }
variable "resourceGroupName" { }
variable "resourceGroupRegion" { }

terraform {
  backend "azurerm" { }
}
