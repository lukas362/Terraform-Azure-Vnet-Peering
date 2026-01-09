terraform {
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            version ="~> 3.0"
        }
    }
}

provider "azurerm" {
    features {}
}

resource "azurerm_resource_group" "jensen" {
    name     = "jensen-resources"
    location = "swedencentral"

    tags = {
        environment = "development"
        owner       = "jensen"
    }
}

resource "azurerm_virtual_network" "vnet_a" {
    name                = "jensen-vnet-a"
    address_space       = ["10.1.0.0/16"]
    location            = azurerm_resource_group.jensen.location
    resource_group_name = azurerm_resource_group.jensen.name
}

resource "azurerm_virtual_network" "vnet_b" {
    name                = "jensen-vnet-b"
    address_space       = ["10.2.0.0/16"]
    location            = azurerm_resource_group.jensen.location
    resource_group_name = azurerm_resource_group.jensen.name
}

resource "azurerm_virtual_network_peering" "a_to_b" {
    name                        = "vnet_a_to_vnet_b"
    resource_group_name         = azurerm_resource_group.jensen.name
    virtual_network_name        = azurerm_virtual_network.vnet_a.name
    remote_virtual_network_id   = azurerm_virtual_network.vnet_b.id
    
    allow_virtual_network_access    = true
    allow_forwarded_traffic         = false
    allow_gateway_transit           = false
    use_remote_gateways             = false
}

resource "azurerm_virtual_network_peering" "b_to_a" {
    name                        = "vnet_b_to_vnet_a"
    resource_group_name         = azurerm_resource_group.jensen.name
    virtual_network_name        = azurerm_virtual_network.vnet_b.name
    remote_virtual_network_id   = azurerm_virtual_network.vnet_a.id
    
    allow_virtual_network_access    = true
    allow_forwarded_traffic         = false
    allow_gateway_transit           = false
    use_remote_gateways             = false
}

resource "azurerm_network_security_group" "vnet_a_nsg" {
    name                = "vnet-a-nsg"
    location            = azurerm_resource_group.jensen.location
    resource_group_name = azurerm_resource_group.jensen.name

    security_rule {
        name                       = "https"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "http"
        priority                   = 110
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "allow-ssh"
        priority                   = 120
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
}

resource "azurerm_network_security_group" "vnet_b_nsg" {
    name                = "vnet-b-nsg"
    location            = azurerm_resource_group.jensen.location
    resource_group_name = azurerm_resource_group.jensen.name

    security_rule {
        name                       = "vnet-a"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "10.1.0.0/16"  
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "allow-ssh"
        priority                   = 110
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "deny-all-other-inbound"
        priority                   = 4096
        direction                  = "Inbound"
        access                     = "Deny"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
}

resource "azurerm_subnet" "vnet_a_subnet" {
    name                 = "subnet_a"
    resource_group_name  = azurerm_resource_group.jensen.name
    virtual_network_name = azurerm_virtual_network.vnet_a.name
    address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_subnet" "vnet_b_subnet" {
    name                 = "subnet_b"
    resource_group_name  = azurerm_resource_group.jensen.name
    virtual_network_name = azurerm_virtual_network.vnet_b.name
    address_prefixes     = ["10.2.1.0/24"]
}

resource "azurerm_subnet_network_security_group_association" "vnet_a_nsg_assoc" {
    subnet_id                 = azurerm_subnet.vnet_a_subnet.id
    network_security_group_id = azurerm_network_security_group.vnet_a_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "vnet_b_nsg_assoc" {
    subnet_id                 = azurerm_subnet.vnet_b_subnet.id
    network_security_group_id = azurerm_network_security_group.vnet_b_nsg.id
}