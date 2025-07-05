resource "helm_release" "metallb_load_balancer" {
  name       = "metallb"
  chart      = "metallb"
  version    = "0.15.2"
  repository = "https://metallb.github.io/metallb"
  namespace  = kubernetes_namespace_v1.metallb_system.id
  timeout    = 60
}

resource "helm_release" "metallb_load_balancer_config" {
  depends_on = [helm_release.metallb_load_balancer]
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

# resource "helm_release" "harbor" {
#   depends_on = [
#     helm_release.metallb_load_balancer_config,
#   ]
#   name       = "harbor"
#   chart      = "harbor"
#   version    = "1.17.1"
#   repository = "https://helm.goharbor.io"
#   namespace  = kubernetes_namespace.applications.id
#   timeout    = 60
# }
#
