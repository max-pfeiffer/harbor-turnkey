resource "kubernetes_storage_class_v1" "local" {
  metadata {
    name = "local"
  }
  storage_provisioner = "kubernetes.io/no-provisioner"
  volume_binding_mode = "WaitForFirstConsumer"
}