#Copyright 2024 Agile Cloud Institute, Inc.  (AgileCloudInstitute.io) as described in LICENSE.txt distributed with this project on GitHub.
#Start at https://github.com/AgileCloudInstitute?tab=repositories

resource "azurerm_subnet" "pipelines" {
  name                 = "agentsSubnet"
  resource_group_name  = data.azurerm_resource_group.pipeline-resources.name
  virtual_network_name = data.azurerm_virtual_network.vnetTarget.name
  address_prefixes     = [var.cidrSubnet]
  service_endpoints    = ["Microsoft.Sql", "Microsoft.Storage", "Microsoft.KeyVault"]
}

## Create Network Security Group and rule
resource "azurerm_network_security_group" "myterraformnsg" {
    name                = "agentsSecurityGroup"
    location            = data.azurerm_resource_group.pipeline-resources.location
    resource_group_name = data.azurerm_resource_group.pipeline-resources.name
    
    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        #For the next two lines, replace * with specific values before this goes to production.  For now, we are keeping this demo simple with *.  
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "Terraform Demo"
    }
}

data "azurerm_image" "search" {
  name_regex     = "${var.imageName}*"
  resource_group_name = data.azurerm_resource_group.pipeline-resources.name
}

resource "azurerm_linux_virtual_machine_scale_set" "myterraformvmss" {
  name                = "myVMSS"
  resource_group_name = data.azurerm_resource_group.pipeline-resources.name
  location            = data.azurerm_resource_group.pipeline-resources.location
  sku                 = "Standard_DS1_v2"
  instances           = 1
  admin_username = var.adminUser
  admin_password = var.adminPwd
  disable_password_authentication = false
#  depends_on = [azurerm_key_vault.infraPipes]

  custom_data         = filebase64(var.cloudInit)

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  source_image_id = data.azurerm_image.search.id

  boot_diagnostics {
    storage_account_uri = data.azurerm_storage_account.mystorageaccount.primary_blob_endpoint
  }

  network_interface {
    name    = "vmssInterface"
    primary = true
    network_security_group_id = azurerm_network_security_group.myterraformnsg.id
    ip_configuration {
      name      = "internal"
      version   = "IPv4"
      subnet_id = azurerm_subnet.pipelines.id
      #Start of public ip block to be removed after development phase//////////////////////////////
      public_ip_address {
        name                = "public-ip-address"
      }
      #End of public IP block to be removed after development phase//////////////////////////////
    }

  }
  tags = {
      environment = "Terraform Demo"
  }

}
