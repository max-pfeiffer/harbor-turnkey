resource "proxmox_vm_qemu" "kubernetes_control_plane" {
  depends_on  = [proxmox_storage_iso.talos_linux_iso_image]
  name        = var.node_data.hostname
  description = "Kubernetes Control Plane"
  target_node = var.proxmox_target_node
  agent       = 1
  vm_state    = "running"
  memory      = 8192
  boot        = "order=virtio0;ide2"
  onboot      = true
  nameserver  = var.domain_name_server

  cpu {
    cores = 2
  }

  vga {
    type = "std"
  }

  disk {
    slot    = "ide0"
    type    = "cloudinit"
    storage = var.proxmox_storage_device
  }

  disk {
    slot = "ide2"
    type = "cdrom"
    iso  = "local:iso/${local.talos_linux_iso_image_filename}"
  }

  disk {
    slot    = "virtio0"
    type    = "disk"
    storage = var.proxmox_storage_device
    size    = "50G"
    discard = true
  }

  disk {
    slot    = "virtio1"
    type    = "disk"
    storage = var.proxmox_storage_device
    size    = "225G"
    discard = true
  }

  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr0"
    tag    = var.vlan_tag
  }

  # Cloud init setup
  os_type   = "cloud-init"
  ipconfig0 = "ip=${var.node_data.ip_address}/24,gw=${var.network_gateway}"
}