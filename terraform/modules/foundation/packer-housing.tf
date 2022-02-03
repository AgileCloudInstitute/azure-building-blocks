#Copyright 2021 Green River IT (GreenRiverIT.com) as described in LICENSE.txt distributed with this project on GitHub.
#Start at https://github.com/AgileCloudInstitute?tab=repositories


resource "azurerm_subnet" "packer-builds-housing" {
  name                 = "imageBuilderSubnet"
  resource_group_name  = azurerm_resource_group.pipelines.name
  virtual_network_name = azurerm_virtual_network.pipelines.name
  address_prefixes     = [var.cidrSubnetPacker]
  service_endpoints    = ["Microsoft.Sql", "Microsoft.Storage", "Microsoft.KeyVault"]
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "packer-builds-housing" {
    name                = "imageBuilderSecurityGroup"
    location            = azurerm_resource_group.pipelines.location
    resource_group_name = azurerm_resource_group.pipelines.name
    
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
        environment = "Packer Demo"
    }
}

# Create public IPs
resource "azurerm_public_ip" "packer-builds-housing" {
    name                = "imageBuilderPublicIP"
    location            = azurerm_resource_group.pipelines.location
    resource_group_name = azurerm_resource_group.pipelines.name
    allocation_method   = "Dynamic"

    tags = {
        environment = "Packer Demo"
    }
}


# Create network interface
resource "azurerm_network_interface" "packer-builds-housing" {
    name                      = "imageBuilderNIC"
    location                  = azurerm_resource_group.pipelines.location
    resource_group_name       = azurerm_resource_group.pipelines.name

    ip_configuration {
        name                          = "imageBuilderNICConfiguration"
        subnet_id                     = azurerm_subnet.packer-builds-housing.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.packer-builds-housing.id
    }

    tags = {
        environment = "Packer Demo"
    }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "packer-builds-housing" {
    network_interface_id      = azurerm_network_interface.packer-builds-housing.id
    network_security_group_id = azurerm_network_security_group.packer-builds-housing.id
}
