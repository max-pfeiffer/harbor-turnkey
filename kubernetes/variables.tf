variable "kubernetes_config_path" {
  type      = string
  sensitive = true
}

variable "Kubernetes_config_context" {
  type      = string
  sensitive = true
}

variable "kubernetes_node_name" {
  description = "Hostname of the Kubernetes node the local PersistentVolumes are pinned to. Must match node_data.hostname of the proxmox module, otherwise no volume can be bound and the pods stay pending."
  type        = string
  default     = "kubernetes-harbor"
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
  default   = null
}

variable "github_password" {
  type      = string
  sensitive = true
  default   = null
}

variable "cilium_load_balancer_ip_range_start" {
  type = string
}

variable "cilium_load_balancer_ip_range_stop" {
  type = string
}

variable "ca_name" {
  description = "Name of the certificate authority, used in the subject of the root and intermediate certificate."
  type        = string
  default     = "Harbor"
}

variable "root_ca_validity_hours" {
  description = "Validity of the root CA certificate. Renewing it invalidates every trust store it was distributed to, so it is deliberately long lived."
  type        = number
  default     = 87600 # 10 years
}

variable "intermediate_ca_validity_hours" {
  description = "Validity of the intermediate CA certificate step-ca signs with."
  type        = number
  default     = 43800 # 5 years
}

variable "intermediate_ca_early_renewal_hours" {
  description = "How long before its expiry the intermediate CA certificate is renewed by the next apply."
  type        = number
  default     = 2160 # 90 days
}

variable "certificate_default_duration" {
  description = "Validity of the certificates step-ca issues when the request does not ask for a specific duration."
  type        = string
  default     = "720h" # 30 days
}

variable "certificate_max_duration" {
  description = "Maximum validity of the certificates step-ca issues."
  type        = string
  default     = "2160h" # 90 days
}
