terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.37.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.0.2"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
    harbor = {
      source  = "goharbor/harbor"
      version = "3.10.21"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
}

provider "harbor" {
  url = var.harbor_url
  username = "admin"
  password = random_password.harbor_admin_password.result
}