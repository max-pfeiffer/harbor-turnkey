terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.0.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.1.1"
    }
    harbor = {
      source  = "goharbor/harbor"
      version = "3.11.3"
    }
  }
}

provider "kubernetes" {
  config_path    = var.kubernetes_config_path
  config_context = var.Kubernetes_config_context
}

provider "helm" {
  kubernetes = {
    config_path    = var.kubernetes_config_path
    config_context = var.Kubernetes_config_context
  }
}

provider "harbor" {
  url      = var.harbor_url
  username = "admin"
  password = var.harbor_admin_password
  insecure = true
}