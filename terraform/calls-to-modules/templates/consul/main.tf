#Copyright 2021 Green River IT (GreenRiverIT.com) as described in LICENSE.txt distributed with this project on GitHub.
#Start at https://github.com/AgileCloudInstitute?tab=repositories

module "consul" {
  source = "..\\..\\..\\modules\\consul"

  subscriptionId         = var.subscriptionId
  tenantId               = var.tenantId
  clientId               = var.clientId
  clientSecret           = var.clientSecret
  resourceGroupName      = var.resourceGroupName
  resourceGroupLocation  = var.resourceGroupLocation
  vnetName               = var.vnetName
  cidrSubnet             = var.cidrSubnet
  imageName              = var.imageName
  adminUser              = var.adminUser
  adminPwd               = var.adminPwd
  vaultName              = var.vaultName
  cloudInit              = var.cloudInit
  storageAccountDiagName = var.storageAccountDiagName

}

##Input variables.  The client referred to is an App Registration.
variable "subscriptionId" { }
variable "tenantId" { }
variable "clientId" { }
variable "clientSecret" { }
variable "resourceGroupName" { }
variable "resourceGroupLocation" { }
variable "vnetName" { }
variable "cidrSubnet" { }
variable "imageName" { }
variable "adminUser" { }
variable "adminPwd" { }
variable "vaultName" { }
variable "cloudInit" { }
variable "storageAccountDiagName" { }


##Output variables
output "admin_ip_body" { value = module.consul.admin_ip_body }
output "admin_cider" { value = module.consul.admin_cider }
