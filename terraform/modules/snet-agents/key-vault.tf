#Copyright 2021 Green River IT (GreenRiverIT.com) as described in LICENSE.txt distributed with this project on GitHub.
#Start at https://github.com/AgileCloudInstitute?tab=repositories

##Now create a key vault as an experiment.  The following will need to be matured later:
resource "azurerm_key_vault" "infraPipes" {
  name                        = var.vaultName
  location                    = data.azurerm_resource_group.pipeline-resources.location
  resource_group_name         = data.azurerm_resource_group.pipeline-resources.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
#  soft_delete_enabled         = true
  purge_protection_enabled    = false
  sku_name = "standard"

  network_acls {
    ##CHANGE THE FOLLOWING LINE TO "Deny" FOR PRODUCTION.
    default_action = "Allow"
    bypass         = "AzureServices"
    ip_rules       = [local.admin-external-cidr]
    virtual_network_subnet_ids = [azurerm_subnet.pipelines.id]
  }

  tags = { environment = "Testing" }

}

##Use this data source to access the configuration of the azurerm provider, which you configured above:
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault_access_policy" "userCreatedSP" {
  key_vault_id = azurerm_key_vault.infraPipes.id
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = var.clientId
  certificate_permissions = [ "Create", "Delete", "DeleteIssuers", "Get", "GetIssuers", "Import", "List", "ListIssuers", "ManageContacts", "ManageIssuers", "SetIssuers", "Update", ]
  key_permissions = [ "Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "Import", "List", "Purge", "Recover", "Restore", "Sign", "UnwrapKey", "Update", "Verify", "WrapKey", ]
  secret_permissions = [ "Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set", ]
  storage_permissions = [ "Get", ]
}

resource "azurerm_key_vault_access_policy" "userCreatedSP2" {
  key_vault_id = azurerm_key_vault.infraPipes.id
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id
  certificate_permissions = [ "Create", "Delete", "DeleteIssuers", "Get", "GetIssuers", "Import", "List", "ListIssuers", "ManageContacts", "ManageIssuers", "SetIssuers", "Update", ]
  key_permissions = [ "Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "Import", "List", "Purge", "Recover", "Restore", "Sign", "UnwrapKey", "Update", "Verify", "WrapKey", ]
  secret_permissions = [ "Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set", ]
  storage_permissions = [ "Get", ]
}


##Now create secrets and attach to the new key vault.
resource "azurerm_key_vault_secret" "subscriptionId" {
  name         = "subscription-id"
  value        = data.azurerm_client_config.current.subscription_id
  key_vault_id = azurerm_key_vault.infraPipes.id
  tags = { environment = "Testing" }
  depends_on = [azurerm_key_vault_access_policy.userCreatedSP, azurerm_key_vault_access_policy.userCreatedSP2]
}

resource "azurerm_key_vault_secret" "tenantId" {
  name         = "tenant-id"
  value        = var.tenantId
  key_vault_id = azurerm_key_vault.infraPipes.id
  tags = { environment = "Testing" }
  depends_on = [azurerm_key_vault_access_policy.userCreatedSP, azurerm_key_vault_access_policy.userCreatedSP2]
}

resource "azurerm_key_vault_secret" "clientId" {
  name         = "client-id"
  value        = var.clientId
  key_vault_id = azurerm_key_vault.infraPipes.id
  tags = { environment = "Testing" }
  depends_on = [azurerm_key_vault_access_policy.userCreatedSP, azurerm_key_vault_access_policy.userCreatedSP2]
}

resource "azurerm_key_vault_secret" "clientSecret" {
  name         = "client-secret"
  value        = var.clientSecret
  key_vault_id = azurerm_key_vault.infraPipes.id
  tags = { environment = "Testing" }
  depends_on = [azurerm_key_vault_access_policy.userCreatedSP, azurerm_key_vault_access_policy.userCreatedSP2]
}

resource "azurerm_key_vault_secret" "gitUser" {
  name         = "git-user"
  value        = var.gitUser
  key_vault_id = azurerm_key_vault.infraPipes.id
  tags = { environment = "Testing" }
  depends_on = [azurerm_key_vault_access_policy.userCreatedSP, azurerm_key_vault_access_policy.userCreatedSP2]
}

resource "azurerm_key_vault_secret" "gitPwd" {
  name         = "git-pwd"
  value        = var.gitPwd
  key_vault_id = azurerm_key_vault.infraPipes.id
  tags = { environment = "Testing" }
  depends_on = [azurerm_key_vault_access_policy.userCreatedSP, azurerm_key_vault_access_policy.userCreatedSP2]
}
