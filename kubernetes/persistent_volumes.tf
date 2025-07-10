resource "kubernetes_persistent_volume_v1" "local_large_1" {
  metadata {
    name = "local-large-1"
  }
  spec {
    capacity = {
      storage = "200Gi"
    }
    access_modes                     = ["ReadWriteOnce"]
    volume_mode                      = "Filesystem"
    persistent_volume_reclaim_policy = "Delete"
    storage_class_name               = "local"
    persistent_volume_source {
      local {
        path = "/var/mnt/local-large-1"
      }
    }
    node_affinity {
      required {
        node_selector_term {
          match_expressions {
            key      = "kubernetes.io/hostname"
            operator = "In"
            values   = ["kubernetes-harbor"]
          }
        }
      }
    }
  }
}

resource "kubernetes_persistent_volume_v1" "local_small_1" {
  metadata {
    name = "local-small-1"
  }
  spec {
    capacity = {
      storage = "5Gi"
    }
    access_modes                     = ["ReadWriteOnce"]
    volume_mode                      = "Filesystem"
    persistent_volume_reclaim_policy = "Delete"
    storage_class_name               = "local"
    persistent_volume_source {
      local {
        path = "/var/mnt/local-small-1"
      }
    }
    node_affinity {
      required {
        node_selector_term {
          match_expressions {
            key      = "kubernetes.io/hostname"
            operator = "In"
            values   = ["kubernetes-harbor"]
          }
        }
      }
    }
  }
}

resource "kubernetes_persistent_volume_v1" "local_small_2" {
  metadata {
    name = "local-small-2"
  }
  spec {
    capacity = {
      storage = "5Gi"
    }
    access_modes                     = ["ReadWriteOnce"]
    volume_mode                      = "Filesystem"
    persistent_volume_reclaim_policy = "Delete"
    storage_class_name               = "local"
    persistent_volume_source {
      local {
        path = "/var/mnt/local-small-2"
      }
    }
    node_affinity {
      required {
        node_selector_term {
          match_expressions {
            key      = "kubernetes.io/hostname"
            operator = "In"
            values   = ["kubernetes-harbor"]
          }
        }
      }
    }
  }
}

resource "kubernetes_persistent_volume_v1" "local_small_3" {
  metadata {
    name = "local-small-3"
  }
  spec {
    capacity = {
      storage = "5Gi"
    }
    access_modes                     = ["ReadWriteOnce"]
    volume_mode                      = "Filesystem"
    persistent_volume_reclaim_policy = "Delete"
    storage_class_name               = "local"
    persistent_volume_source {
      local {
        path = "/var/mnt/local-small-3"
      }
    }
    node_affinity {
      required {
        node_selector_term {
          match_expressions {
            key      = "kubernetes.io/hostname"
            operator = "In"
            values   = ["kubernetes-harbor"]
          }
        }
      }
    }
  }
}

resource "kubernetes_persistent_volume_v1" "local_small_4" {
  metadata {
    name = "local-small-4"
  }
  spec {
    capacity = {
      storage = "5Gi"
    }
    access_modes                     = ["ReadWriteOnce"]
    volume_mode                      = "Filesystem"
    persistent_volume_reclaim_policy = "Delete"
    storage_class_name               = "local"
    persistent_volume_source {
      local {
        path = "/var/mnt/local-small-4"
      }
    }
    node_affinity {
      required {
        node_selector_term {
          match_expressions {
            key      = "kubernetes.io/hostname"
            operator = "In"
            values   = ["kubernetes-harbor"]
          }
        }
      }
    }
  }
}

resource "kubernetes_persistent_volume_v1" "local_small_5" {
  metadata {
    name = "local-small-5"
  }
  spec {
    capacity = {
      storage = "5Gi"
    }
    access_modes                     = ["ReadWriteOnce"]
    volume_mode                      = "Filesystem"
    persistent_volume_reclaim_policy = "Delete"
    storage_class_name               = "local"
    persistent_volume_source {
      local {
        path = "/var/mnt/local-small-5"
      }
    }
    node_affinity {
      required {
        node_selector_term {
          match_expressions {
            key      = "kubernetes.io/hostname"
            operator = "In"
            values   = ["kubernetes-harbor"]
          }
        }
      }
    }
  }
}
