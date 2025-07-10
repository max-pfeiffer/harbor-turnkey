variable "harbor_admin_password" {
  type      = string
  sensitive = true
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

variable "root_ca_password" {
  type      = string
  sensitive = true
}

variable "harbor_url" {
  type    = string
  default = "https://harbor.lan"
}
