#Copyright 2021 Green River IT (GreenRiverIT.com) as described in LICENSE.txt distributed with this project on GitHub.
#Start at https://github.com/AgileCloudInstitute?tab=repositories

####################################################################################################################
####Define the input variables:  
####################################################################################################################
#Make sure the subscription is correct, as we are using multiple subscriptions to segregate work

###The following are for 2nd iteration
variable "subscriptionId" { }
variable "tenantId" { }
#The client referred to is an App Registration.  Here, we are using "AppPipes" app registration we create for the second subscription.
variable "clientId" { }
variable "clientSecret" { }
variable "resourceGroupName" { }
variable "vnetName" { }
variable "cidrSubnet" { }

##Manually imported things need placeholders as follows:

data "azurerm_resource_group" "pipeline-resources" {
  name = var.resourceGroupName
}

data "azurerm_virtual_network" "vnetTarget" {
  name                = var.vnetName
  resource_group_name = data.azurerm_resource_group.pipeline-resources.name
}
