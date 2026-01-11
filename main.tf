# Required provider (Azure) and what version version
terraform {
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            version ="~> 3.0"
        }
    }
}

# Configure the provider (Azure) 
provider "azurerm" {
    features {}
}

# container that holds Azure resources 
resource "azurerm_resource_group" "jensen" {
    name     = "jensen-resources"
    location = "swedencentral"

    tags = {
        environment = "development"
        owner       = "Owner_Name"    # Owner name here 
    }
}

# VNet A
resource "azurerm_virtual_network" "vnet_a" {
    name                = "jensen-vnet-a"
    address_space       = ["10.1.0.0/16"]
    location            = azurerm_resource_group.jensen.location
    resource_group_name = azurerm_resource_group.jensen.name     # Needs to be name here 
}

# VNet B
resource "azurerm_virtual_network" "vnet_b" {
    name                = "jensen-vnet-b"
    address_space       = ["10.2.0.0/16"]
    location            = azurerm_resource_group.jensen.location
    resource_group_name = azurerm_resource_group.jensen.name     # Needs to be name here 
}

# VNet Peering (Allows communication between with diffrent VNets) 

# Peering from VNet A to VNet B
resource "azurerm_virtual_network_peering" "a_to_b" {
    name                        = "vnet_a_to_vnet_b"
    resource_group_name         = azurerm_resource_group.jensen.name
    virtual_network_name        = azurerm_virtual_network.vnet_a.name
    remote_virtual_network_id   = azurerm_virtual_network.vnet_b.id     # Needs to be id here 
    
    allow_virtual_network_access    = true        # Allow VMs in VNet A to access VNet B (Default = true) 
    allow_forwarded_traffic         = false       # Denies fowards traffic (Default = false)     
    allow_gateway_transit           = false       # Doesn't allow VNet A to use VNet B gateway (Default = false) 
    use_remote_gateways             = false       # Controls if remote gateways can be used on the local virtual network (Default = false) 
}

resource "azurerm_virtual_network_peering" "b_to_a" {
    name                        = "vnet_b_to_vnet_a"
    resource_group_name         = azurerm_resource_group.jensen.name
    virtual_network_name        = azurerm_virtual_network.vnet_b.name
    remote_virtual_network_id   = azurerm_virtual_network.vnet_a.id     # Needs to be id here 
    
    allow_virtual_network_access    = true         # Allow VMs in VNet B to access VNet A (Default = true)
    allow_forwarded_traffic         = false        # Denies fowards traffic (Default = false)  
    allow_gateway_transit           = false        # Doesn't allow VNet A to use VNet B gateway (Default = false) 
    use_remote_gateways             = false        # Controls if remote gateways can be used on the local virtual network (Default = false) 
}

# NSGs
# NSG allows for traffic from internet 
resource "azurerm_network_security_group" "vnet_a_nsg" {
    name                = "vnet-a-nsg"
    location            = azurerm_resource_group.jensen.location
    resource_group_name = azurerm_resource_group.jensen.name

#Allow HTTPS traffic from port 443 
    security_rule {
        name                       = "https"
        priority                   = 100            # Priority 100 goes first as it has the lowest priority 
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

#Allow HTTP traffic from port 80 
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

#Allow SSH access from port 22 
    security_rule {
        name                       = "allow-ssh"
        priority                   = 120
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "IP here" # Specific IP address 
        destination_address_prefix = "*"
    }
}

# NSG allows traffic from VNet A  
resource "azurerm_network_security_group" "vnet_b_nsg" {
    name                = "vnet-b-nsg"
    location            = azurerm_resource_group.jensen.location
    resource_group_name = azurerm_resource_group.jensen.name

    security_rule {
        name                       = "vnet-a"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*" # Any protocol 
        source_port_range          = "*"
        destination_port_range     = "*" # Any port 
        source_address_prefix      = "10.1.0.0/16" # Only traffic from VNet A 
        destination_address_prefix = "*"
    }

# SSH access
    security_rule {
        name                       = "allow-ssh"
        priority                   = 110
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "10.1.0.0/16"
        destination_address_prefix = "*"
    }

# Any other traffic will be denied 
    security_rule {
        name                       = "deny-all-other-inbound"
        priority                   = 4096            # Lowest possible priority 
        direction                  = "Inbound"
        access                     = "Deny"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
}

# Subnets 
# Subnet in VNet A 
resource "azurerm_subnet" "vnet_a_subnet" {
    name                 = "subnet_a"
    resource_group_name  = azurerm_resource_group.jensen.name
    virtual_network_name = azurerm_virtual_network.vnet_a.name
    address_prefixes     = ["10.1.1.0/24"]
}

# Subnet in VNet B
resource "azurerm_subnet" "vnet_b_subnet" {
    name                 = "subnet_b"
    resource_group_name  = azurerm_resource_group.jensen.name
    virtual_network_name = azurerm_virtual_network.vnet_b.name
    address_prefixes     = ["10.2.1.0/24"]
}

# NSG associations (Applies the security rules stated before onto the VNets 
# Apply NSG to VNet A subnet 
resource "azurerm_subnet_network_security_group_association" "vnet_a_nsg_assoc" {
    subnet_id                 = azurerm_subnet.vnet_a_subnet.id
    network_security_group_id = azurerm_network_security_group.vnet_a_nsg.id
}

# Apply NSG to VNet B subnet 
resource "azurerm_subnet_network_security_group_association" "vnet_b_nsg_assoc" {
    subnet_id                 = azurerm_subnet.vnet_b_subnet.id
    network_security_group_id = azurerm_network_security_group.vnet_b_nsg.id

}
