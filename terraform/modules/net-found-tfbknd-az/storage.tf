#Copyright 2021 Green River IT (GreenRiverIT.com) as described in LICENSE.txt distributed with this project on GitHub.
#Start at https://github.com/AgileCloudInstitute?tab=repositories

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "diagstorageaccount" {
    name                        = "diag${random_id.randomId.hex}"
    location                    = azurerm_resource_group.backends.location
    resource_group_name         = azurerm_resource_group.backends.name
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags = {
        environment = "Terraform Demo"
    }
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = azurerm_resource_group.backends.name
    }
    
    byte_length = 8
}

#Note: A storage account for each Terraform Backend will be created separately when each AZDO pipeline is attached to this.
