#Copyright 2021 Green River IT (GreenRiverIT.com) as described in LICENSE.txt distributed with this project on GitHub.
#Start at https://github.com/AgileCloudInstitute?tab=repositories

resource "azurerm_subnet" "pipelines" {
  name                 = "imageBuilderSubnet"
  resource_group_name  = var.resourceGroupName
  virtual_network_name = data.azurerm_virtual_network.vnetTarget.name
  address_prefixes     = [var.cidrSubnet]
  service_endpoints    = ["Microsoft.Sql", "Microsoft.Storage", "Microsoft.KeyVault"]
}

## Create Network Security Group and rule
resource "azurerm_network_security_group" "myterraformnsg" {
    name                = "imageBuilderSecurityGroup"
    location            = data.azurerm_resource_group.pipeline-resources.location
    resource_group_name = data.azurerm_resource_group.pipeline-resources.name
    tags = {
        environment = "Terraform Demo"
    }

    #SSH rule
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

    ##########Consul rules
    #8300,8301,8302,8400,8500,8600}/tcp
    #8301,8302,8600}/udp
    #Inbound rules
    security_rule {
        name                       = "Consul_8300_Inbound"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "8300"
        #For the next two lines, replace * with specific values before this goes to production.  For now, we are keeping this demo simple with *.  
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
    security_rule {
        name                       = "Consul_8301_Inbound"
        priority                   = 1003
        direction                  = "Inbound"
        access                     = "Allow"
        #The following is set to * to simplify both tcp and udp during development.  Make a work item to lock this down tighter before this goes to production.
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "8301"
        #For the next two lines, replace * with specific values before this goes to production.  For now, we are keeping this demo simple with *.  
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
    security_rule {
        name                       = "Consul_8302_Inbound"
        priority                   = 1004
        direction                  = "Inbound"
        access                     = "Allow"
        #The following is set to * to simplify both tcp and udp during development.  Make a work item to lock this down tighter before this goes to production.
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "8302"
        #For the next two lines, replace * with specific values before this goes to production.  For now, we are keeping this demo simple with *.  
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
    security_rule {
        name                       = "Consul_8400_Inbound"
        priority                   = 1005
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "8400"
        #For the next two lines, replace * with specific values before this goes to production.  For now, we are keeping this demo simple with *.  
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
    security_rule {
        name                       = "Consul_8500_Inbound"
        priority                   = 1006
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "8500"
        #For the next two lines, replace * with specific values before this goes to production.  For now, we are keeping this demo simple with *.  
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
    security_rule {
        name                       = "Consul_8600_Inbound"
        priority                   = 1007
        direction                  = "Inbound"
        access                     = "Allow"
        #The following is set to * to simplify both tcp and udp during development.  Make a work item to lock this down tighter before this goes to production.
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "8600"
        #For the next two lines, replace * with specific values before this goes to production.  For now, we are keeping this demo simple with *.  
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    #Outbound rules
    security_rule {
        name                       = "Consul_8300_Outbound"
        priority                   = 1008
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "8300"
        #For the next two lines, replace * with specific values before this goes to production.  For now, we are keeping this demo simple with *.  
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
    security_rule {
        name                       = "Consul_8301_Outbound"
        priority                   = 1009
        direction                  = "Outbound"
        access                     = "Allow"
        #The following is set to * to simplify both tcp and udp during development.  Make a work item to lock this down tighter before this goes to production.
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "8301"
        #For the next two lines, replace * with specific values before this goes to production.  For now, we are keeping this demo simple with *.  
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
    security_rule {
        name                       = "Consul_8302_Outbound"
        priority                   = 1010
        direction                  = "Outbound"
        access                     = "Allow"
        #The following is set to * to simplify both tcp and udp during development.  Make a work item to lock this down tighter before this goes to production.
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "8302"
        #For the next two lines, replace * with specific values before this goes to production.  For now, we are keeping this demo simple with *.  
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
    security_rule {
        name                       = "Consul_8400_Outbound"
        priority                   = 1011
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "8400"
        #For the next two lines, replace * with specific values before this goes to production.  For now, we are keeping this demo simple with *.  
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
    security_rule {
        name                       = "Consul_8500_Outbound"
        priority                   = 1012
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "8500"
        #For the next two lines, replace * with specific values before this goes to production.  For now, we are keeping this demo simple with *.  
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
    security_rule {
        name                       = "Consul_8600_Outbound"
        priority                   = 1013
        direction                  = "Outbound"
        access                     = "Allow"
        #The following is set to * to simplify both tcp and udp during development.  Make a work item to lock this down tighter before this goes to production.
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "8600"
        #For the next two lines, replace * with specific values before this goes to production.  For now, we are keeping this demo simple with *.  
        source_address_prefix      = "*"
        destination_address_prefix = "*"
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
