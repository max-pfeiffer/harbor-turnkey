variable "proxmox_api_url" {
  description = "Endpoint of the Proxmox VE API, i.e. https://<your-cluster-endpoint>:8006/ without the /api2/json suffix"
  type        = string
}

variable "proxmox_api_token_id" {
  description = "Proxmox API token id in the form <username>@<realm>!<token-name>"
  type        = string
  sensitive   = true
}

variable "proxmox_api_token_secret" {
  description = "Proxmox API token secret"
  type        = string
  sensitive   = true
}

variable "proxmox_target_node" {
  type = string
}

variable "proxmox_storage_device" {
  type = string
}

variable "talos_version" {
  type    = string
  default = "1.13.8"
}

variable "kubernetes_version" {
  type    = string
  default = "1.36.3"
}

variable "talos_linux_iso_image_url" {
  description = "URL of the Talos ISO image for initially booting the VM"
  type        = string
  default     = "https://factory.talos.dev/image/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515/v1.13.8/nocloud-amd64.iso"
}

variable "talos_linux_iso_image_filename" {
  description = "Filename of the Talos ISO image for initially booting the VM"
  type        = string
  default     = "talos-linux-v1.13.8-qemu-guest-agent-amd64.iso"
}

variable "cluster_name" {
  description = "A name to provide for the Talos cluster"
  type        = string
  default     = "talos"
}

variable "node_data" {
  description = "A map of node data"
  type = object({
    ip_address    = string
    install_disk  = string
    install_image = string
    hostname      = string
  })
}

variable "network" {
  description = "Network for all nodes"
  type        = string
}

variable "network_gateway" {
  description = "Network gateway for all nodes"
  type        = string
}

variable "domain_name_server" {
  description = "DNS for all nodes"
  type        = string
}

variable "vlan_tag" {
  description = "Vlan tag for all nodes, default does not configure a Vlan"
  type        = number
  default     = 0
}
