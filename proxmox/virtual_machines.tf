resource "proxmox_virtual_environment_vm" "kubernetes_control_plane" {
  name        = var.node_data.hostname
  description = "Kubernetes Control Plane"
  node_name   = var.proxmox_target_node
  started     = true
  on_boot     = true
  boot_order  = ["virtio0", "ide2"]

  agent {
    enabled = true
  }

  operating_system {
    type = "l26"
  }

  cpu {
    cores = 2
    type  = "host"
  }

  memory {
    dedicated = 8192
  }

  vga {
    type = "std"
  }


  cdrom {
    interface = "ide2"
    file_id   = proxmox_download_file.talos_linux_iso_image.id
  }

  disk {
    interface    = "virtio0"
    datastore_id = var.proxmox_storage_device
    size         = 50
    discard      = "on"
  }

  disk {
    interface    = "virtio1"
    datastore_id = var.proxmox_storage_device
    size         = 225
    discard      = "on"
  }

  network_device {
    model   = "virtio"
    bridge  = "vmbr0"
    vlan_id = var.vlan_tag
  }

  # Cloud init setup
  initialization {
    interface    = "ide0"
    datastore_id = var.proxmox_storage_device

    dns {
      servers = [var.domain_name_server]
    }

    ip_config {
      ipv4 {
        address = "${var.node_data.ip_address}/24"
        gateway = var.network_gateway
      }
    }
  }
}
