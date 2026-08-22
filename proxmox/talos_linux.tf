resource "talos_machine_secrets" "this" {}

data "talos_machine_configuration" "controlplane" {
  cluster_name       = var.cluster_name
  cluster_endpoint   = "https://${var.node_data.ip_address}:6443"
  machine_type       = "controlplane"
  machine_secrets    = talos_machine_secrets.this.machine_secrets
  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version
  config_patches = concat(
    [
      templatefile("${path.module}/machine_config_patches/controlplane.tftpl", {
        hostname             = var.node_data.hostname
        install_disk         = var.node_data.install_disk
        install_image        = var.node_data.install_image
        dns                  = var.domain_name_server
        ip_address           = "${var.node_data.ip_address}/24"
        network              = var.network
        network_gateway      = var.network_gateway
        gateway_api_manifest = file("${path.module}/gateway-api/gateway-api-crds-v1.6.1.yaml")
        cilium_manifest      = data.helm_template.cilium.manifest
      }),
    ],
    # Without a hostname Talos Linux generates one itself
    var.node_data.hostname != null ? [
      templatefile("${path.module}/machine_config_patches/machine_config_patch_hostname.tftpl", {
        hostname = var.node_data.hostname
      })
    ] : [],
    [file("${path.module}/machine_config_patches/uservolumes.yaml")],
  )
}

data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = [var.node_data.ip_address]
}

resource "talos_machine" "controlplane" {
  depends_on = [proxmox_virtual_environment_vm.kubernetes_control_plane]

  node                  = var.node_data.ip_address
  client_configuration  = talos_machine_secrets.this.client_configuration
  machine_configuration = data.talos_machine_configuration.controlplane.machine_configuration
  image                 = var.node_data.install_image
  # This is a single node cluster: draining the only node would evict all workloads
  # for every upgrade. It also is not obtainable here, as draining needs a kubeconfig
  # which talos_cluster_kubeconfig.this provides: that resource depends on bootstrap,
  # which depends on this resource, so wiring it up would create a dependency cycle.
  drain_on_upgrade = false
}

resource "talos_machine_bootstrap" "this" {
  depends_on = [talos_machine.controlplane]

  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = var.node_data.ip_address
}

resource "talos_cluster_kubeconfig" "this" {
  depends_on           = [talos_machine_bootstrap.this]
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = var.node_data.ip_address
}
