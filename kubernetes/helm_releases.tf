resource "helm_release" "metallb_load_balancer" {
  depends_on = [kubernetes_namespace.metallb_system]
  name       = "metallb"
  chart      = "metallb"
  version    = "0.14.9"
  repository = "https://metallb.github.io/metallb"
  namespace  = kubernetes_namespace.metallb_system.id
  timeout    = 300
}

resource "helm_release" "metallb_load_balancer_config" {
  depends_on = [helm_release.metallb_load_balancer]
  name       = "metallb-config"
  chart      = "${path.module}/helm_charts/metallb-config"
  namespace  = kubernetes_namespace.metallb_system.id
  timeout    = 60
}

resource "helm_release" "nginx_ingress_controller" {
  depends_on = [
    helm_release.metallb_load_balancer_config,
  ]
  name       = "ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.11.4"
  repository = "https://kubernetes.github.io/ingress-nginx"
  namespace  = kubernetes_namespace.ingress.id
  timeout    = 300
}
