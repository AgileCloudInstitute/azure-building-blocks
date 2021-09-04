#Copyright 2021 Green River IT (GreenRiverIT.com) as described in LICENSE.txt distributed with this project on GitHub.
#Start at https://github.com/AgileCloudInstitute?tab=repositories

provider "azurerm" {
    subscription_id = var.subscriptionId
    client_id       = var.clientId
    client_secret   = var.clientSecret
    tenant_id       = var.tenantId

    #The following features block will prevent Azure from retaining the key vault each time you run terraform destroy, provided purge is set to "true".  If remove the key_vault feature, make sure to retain an empty features {} block.
    features {
      key_vault {
        purge_soft_delete_on_destroy = true
        recover_soft_deleted_key_vaults = true
      }
    }
}


