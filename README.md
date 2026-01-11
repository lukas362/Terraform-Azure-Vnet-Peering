# Azure VNet Peering with Terraform
Infrastructure as Code (IaC) for deploying a secure, multi-tier Azure network architecture using Terraform. This configuration demonstrates VNet peering and network segmentation with Network Security Groups (NSG).

## Architecture
This template creates two peered Virtual Networks with different functions:

- **VNet A (10.1.0.0/16)**: Facing towards the internet (Frontend)
  - VNet A allows for inbound HTTP (80), HTTPS (443), and SSH (22) from the internet
  - Useful for web servers, as a load balancers or any other type of application that is accessible from the internet

- **VNet B (10.2.0.0/16)**: Private network (Backend)
  - Only accessible from VNet A (10.1.0.0/16) and other trafic is denied by NSG 
  - Adds an extra layer of defence incase VNet A would be attacked or exposed
  - Useful for databases or storing sesitive information 

## What Gets Created

- Two Virtual Networks with peering with eachother 
- Network Security Group rules 
- Subnets in each VNet (10.1.1.0/24 and 10.2.1.0/24)
- NSG rules applied onto specific subnets
- Resource group in Sweden Central region
- DMZ-style network segmentation (by only allowing VNet A to communicate to the internet and restricting VNet B to only communicate with VNet A) 

## Commands 
terraform apply - to create the resource on Azure (thing I wanna create) 

terraform destroy - will destroy the resources on Azure 

terraform plan - will show me the changes that will be made to my configuration. Aka a preview to modify your infrastructure before applying them. 

terraform init - is the first thing you run in a terraform project. It’s like getting your recipe and all ingredients ready before starting baking. terraform init will download tools / plugins, set up your workplace and get modules that you are using. 

Before you can start making Azure infrastructure you need Azure CLI on your powershell 
