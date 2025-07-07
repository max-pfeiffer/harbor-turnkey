
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

variable "harbor_domain" {
  type      = string
  default = "harbor.lan"
}

variable "harbor_url" {
  type      = string
  default = "https://harbor.lan"
}
