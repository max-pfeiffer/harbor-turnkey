resource "kubernetes_namespace_v1" "security" {
  metadata {
    name = "security"
  }
}

resource "kubernetes_namespace_v1" "cert_manager" {
  metadata {
    name = "cert-manager"
  }
}

resource "kubernetes_namespace_v1" "applications" {
  metadata {
    name = "applications"
  }
}

# Namespace for the cluster wide networking resources, currently the Gateway every
# application is published through.
resource "kubernetes_namespace_v1" "network" {
  metadata {
    name = "network"
  }
}
