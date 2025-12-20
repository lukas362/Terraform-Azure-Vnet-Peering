terraform {
    required_providers {
        azurerm = {
            source  = "hashicorp/azurerm"
            version = "~> 3.0"
        }
    }
}

provider "azurerm" {
    features {}
}

resource "azurerm_resource_group" "main" {
    name     = var.resource_group_name
    location = var.location

    tags = {
        environment = var.environment
        owner       = var.owner
    }
}

resource "azurerm_virtual_network" "main" {
    name                = var.vnet_name
    address_space       = var.vnet_address_space
    location            = azurerm_resource_group.main.location
    resource_group_name = azurerm_resource_group.main.name

    tags = {
        environment = var.environment
        owner       = var.owner
    }
}

resource "azurerm_subnet" "main" {
    name                 = var.subnet_name
    resource_group_name  = azurerm_resource_group.main.name
    virtual_network_name = azurerm_virtual_network.main.name
    address_prefixes     = var.subnet_address_prefix
}

