resource "helm_release" "metallb_load_balancer" {
  name       = "metallb"
  chart      = "metallb"
  version    = "0.15.2"
  repository = "https://metallb.github.io/metallb"
  namespace  = kubernetes_namespace_v1.metallb_system.id
  timeout    = 60
}

# resource "helm_release" "cert_manager" {
#   name       = "cert-manager"
#   chart      = "cert-manager"
#   version    = "1.17.1"
#   repository = "https://charts.jetstack.io"
#   namespace  = kubernetes_namespace_v1.cert_manager.id
#   timeout    = 120
#
#   set = [
#     {
#       name  = "crds.enabled"
#       value = "true"
#     }
#   ]
# }

resource "helm_release" "metallb_load_balancer_config" {
  depends_on = [
    helm_release.metallb_load_balancer,
  ]
  name       = "metallb-config"
  chart      = "${path.module}/helm_charts/metallb-config"
  namespace  = kubernetes_namespace_v1.metallb_system.id
  timeout    = 60
}


resource "helm_release" "nginx_ingress_controller" {
  depends_on = [
    helm_release.metallb_load_balancer_config,
  ]
  name       = "ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.12.3"
  repository = "https://kubernetes.github.io/ingress-nginx"
  namespace  = kubernetes_namespace_v1.ingress.id
  timeout    = 60
}

resource "helm_release" "harbor" {
  depends_on = [
    helm_release.nginx_ingress_controller,
    kubernetes_storage_class_v1.local,
    kubernetes_persistent_volume_v1.local_large_1,
    kubernetes_persistent_volume_v1.local_medium_1,
    kubernetes_persistent_volume_v1.local_medium_2,
    kubernetes_persistent_volume_v1.local_small_1,
    kubernetes_persistent_volume_v1.local_small_2,
    kubernetes_persistent_volume_v1.local_small_3,
    kubernetes_persistent_volume_v1.local_small_4,
    kubernetes_persistent_volume_v1.local_small_5,
    kubernetes_persistent_volume_v1.local_small_6,
  ]
  name       = "harbor"
  chart      = "harbor"
  version    = "1.17.1"
  repository = "https://helm.goharbor.io"
  namespace  = kubernetes_namespace_v1.applications.id
  timeout    = 120
  values = [
    templatefile("${path.module}/helm_values/harbor.yaml", {
    })
  ]
}

