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

resource "azurerm_virtual_network" "jensen" {
    name                = "jensen-vnet"
    address_space       = ["10.0.0.0/16"]
    location            = azurerm_resource_group.jensen.location
    resource_group_name = azurerm_resource_group.jensen.name
}

resource "azurerm_subnet" "jensen" {
    name                 = "jensen-subnet"
    resource_group_name   = azurerm_resource_group.jensen.name
    virtual_network_name = azurerm_virtual_network.jensen.name
    address_prefixes     = ["10.0.1.0/24"]
}
