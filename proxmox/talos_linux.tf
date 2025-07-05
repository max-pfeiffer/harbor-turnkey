resource "talos_machine_secrets" "this" {}

data "talos_machine_configuration" "controlplane" {
  cluster_name     = var.cluster_name
  cluster_endpoint = "https://${var.node_data.ip_address}:6443"
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
}

data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = [var.node_data.ip_address]
}

resource "talos_machine_configuration_apply" "controlplane" {
  depends_on                  = [proxmox_vm_qemu.kubernetes_control_plane]
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  node                        = var.node_data.ip_address
  config_patches = [
    templatefile("${path.module}/machine_config_patches/controlplane.tftpl", {
      hostname        = var.node_data.hostname
      install_disk    = var.node_data.install_disk
      install_image   = var.node_data.install_image
      ip_address      = "${var.node_data.ip_address}/24"
      network         = var.network
      network_gateway = var.network_gateway
    }),
    file("${path.module}/machine_config_patches/uservolumes.yaml"),
  ]
}
resource "talos_machine_bootstrap" "this" {
  depends_on = [talos_machine_configuration_apply.controlplane]

  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = var.node_data.ip_address
}

resource "talos_cluster_kubeconfig" "this" {
  depends_on           = [talos_machine_bootstrap.this]
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = var.node_data.ip_address
}