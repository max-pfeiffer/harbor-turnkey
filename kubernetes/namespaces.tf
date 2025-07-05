resource "kubernetes_namespace_v1" "metallb_system" {
  metadata {
    name = "metallb-system"
    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/audit"   = "privileged"
      "pod-security.kubernetes.io/warn"    = "privileged"
    }
  }
}

resource "kubernetes_namespace_v1" "ingress" {
  metadata {
    name = "ingress"
  }
}

resource "kubernetes_namespace_v1" "applications" {
  metadata {
    name = "applications"
  }
}