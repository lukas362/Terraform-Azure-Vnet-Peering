# Azure-Infrastructure-Template
Infrastructure as Code (IaC) for deploying and managing Azure resources using Terraform. This repository provides reusable, variable-driven configurations for creating Azure networking resources across multiple environments and regions.

## When to use 
- Web application: Create VMs, load balancers, databases, storage accounts
- Kubernetes cluster: Set up AKS (Azure Kubernetes Service) with networking
- Data pipeline: Create data lakes, databricks, event hubs
- Backup/disaster recovery: Duplicate infrastructure in different regions


## Commands 
terraform apply - to create the resource on Azure (thing I wanna create) 

terraform destroy - will destroy the resources on Azure 

terraform plan - will show me the changes that will be made to my configuration. Aka a preview to modify your infrastructure before applying them. 

terraform init - is the first thing you run in a terraform project. It’s like getting your recipe and all ingredients ready before starting baking. terraform init will download tools / plugins, set up your workplace and get modules that you are using. 

Before you can start making Azure infrastructure you need Azure CLI on your powershell 
