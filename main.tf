terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.117.1"
    }
  }
}

provider "azurerm" {
  features {}
}

# Create a new resource group
resource "azurerm_resource_group" "aks_rg" {
  name     = "aks-sample-rg"
  location = "eastus"
}

# Create the AKS cluster
resource "azurerm_kubernetes_cluster" "app" {
  name                = "aks-sample-cluster"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix          = "aks-sample"

  default_node_pool {
    name                = "default"
    node_count          = 1
    vm_size             = "Standard_B2s"
    enable_auto_scaling = true
    min_count           = 1
    max_count           = 3
  }

  identity {
    type = "SystemAssigned"
  }

  # Use a supported Kubernetes version from the list (1.31.5 in this case)
  kubernetes_version = "1.31.5"
}

# Output the raw kubeconfig for connecting with kubectl
output "kube_config" {
  value     = azurerm_kubernetes_cluster.app.kube_config_raw
  sensitive = true
}


