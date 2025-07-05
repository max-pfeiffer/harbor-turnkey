resource "kubernetes_persistent_volume_v1" "local" {
  metadata {
    name = "local"
  }
  spec {
    capacity = {
      storage = "250Gi"
    }
    access_modes = ["ReadWriteOnce"]
    volume_mode = "Filesystem"
    persistent_volume_reclaim_policy = "Delete"
    storage_class_name = "local"
    persistent_volume_source {
      local {
        path = "/var/mnt/local"
      }
    }
    node_affinity {
      required {
        node_selector_term {
          match_expressions {
            key      = "kubernetes.io/hostname"
            operator = "In"
            values = ["kubernetes-harbor"]
          }
        }
      }

    }
  }
}