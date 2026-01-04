variable "kubernetes_config_path" {
  type      = string
  sensitive = true
}

variable "Kubernetes_config_context" {
  type      = string
  sensitive = true
}

variable "harbor_admin_password" {
  type      = string
  sensitive = true
}

variable "harbor_domain" {
  type = string
}

variable "harbor_url" {
  type = string
}

variable "docker_hub_username" {
  type      = string
  sensitive = true
}

variable "docker_hub_password" {
  type      = string
  sensitive = true
}

variable "docker_hub_email" {
  type      = string
  sensitive = true
}

variable "github_username" {
  type      = string
  sensitive = true
  default = null
}

variable "github_password" {
  type      = string
  sensitive = true
  default = null
}

variable "cilium_load_balancer_ip_range_start" {
  type = string
}

variable "cilium_load_balancer_ip_range_stop" {
  type = string
}

variable "root_ca_password" {
  type      = string
  sensitive = true
}
