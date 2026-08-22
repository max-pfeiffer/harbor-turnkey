locals {
  harbor_release_name = "harbor"

  # The Gateway every application is published through. Its name, the names of its
  # listeners and the Secret holding its certificate are referenced by the ClusterIssuer
  # and by the Harbor release, so they have to be known before the Gateway exists.
  gateway_name                = "gateway"
  gateway_http_listener_name  = "http"
  gateway_https_listener_name = "https"
  gateway_tls_secret_name     = "harbor-tls"
}

resource "helm_release" "cilium_lb_config" {
  name    = "cilium-lb-config"
  chart   = "${path.module}/helm_charts/cilium-lb-config"
  timeout = 60
  set = [
    {
      name  = "ciliumLoadBalancerIpRange.start"
      value = var.cilium_load_balancer_ip_range_start
    },
    {
      name  = "ciliumLoadBalancerIpRange.stop"
      value = var.cilium_load_balancer_ip_range_stop
    },
  ]
}

resource "helm_release" "step_certificates" {
  depends_on = [
    kubernetes_secret_v1.docker_hub_namespace_security,
    kubernetes_persistent_volume_v1.local_small_1,
    kubernetes_config_map_v1.step_certificates_certs,
    kubernetes_config_map_v1.step_certificates_config,
    kubernetes_secret_v1.step_certificates_secrets,
  ]
  name       = local.step_ca_name
  chart      = "step-certificates"
  version    = "1.30.1"
  repository = "https://smallstep.github.io/helm-charts/"
  namespace  = kubernetes_namespace_v1.security.id
  timeout    = 300
  values = [
    templatefile("${path.module}/helm_values/step-certificates.yaml", {
      ca_material_revision = local.ca_material_revision
    })
  ]
}

resource "helm_release" "cert_manager" {
  depends_on = [
    kubernetes_secret_v1.docker_hub_namespace_cert_manager,
  ]
  name       = "cert-manager"
  chart      = "cert-manager"
  version    = "1.21.1"
  repository = "https://charts.jetstack.io"
  namespace  = kubernetes_namespace_v1.cert_manager.id
  timeout    = 120

  set = [
    {
      name  = "global.imagePullSecrets[0].name"
      value = "docker-hub"
    },
    {
      name  = "crds.enabled"
      value = "true"
    },
    # Gateway API support is what makes cert-manager solve the ACME HTTP-01 challenge
    # with a HTTPRoute attached to the Gateway instead of with an Ingress.
    # See: https://cert-manager.io/docs/usage/gateway/
    {
      name  = "config.gatewayAPI.enabled"
      value = "true"
    }
  ]
}

# The ClusterIssuer lives in a local chart because the cert-manager CRDs it depends on
# only exist after the cert-manager release, which the kubernetes provider cannot express
# for custom resources without failing at plan time.
resource "helm_release" "step_ca_acme_issuer" {
  depends_on = [
    helm_release.step_certificates,
    helm_release.cert_manager,
  ]
  name      = "step-ca-acme-issuer"
  chart     = "${path.module}/helm_charts/step-ca-acme-issuer"
  namespace = kubernetes_namespace_v1.cert_manager.id
  timeout   = 60
  values = [
    templatefile("${path.module}/helm_values/step-ca-acme-issuer.yaml", {
      cluster_issuer_name         = local.acme_cluster_issuer_name
      acme_directory_url          = local.step_ca_acme_directory_url
      ca_bundle                   = base64encode(tls_self_signed_cert.root_ca.cert_pem)
      solver_gateway_name         = local.gateway_name
      solver_gateway_namespace    = kubernetes_namespace_v1.network.id
      solver_gateway_section_name = local.gateway_http_listener_name
    })
  ]
}

# The Gateway is published under the first address of the Cilium load balancer IP range
# and terminates TLS for Harbor. It comes with the cert-manager Certificate for its HTTPS
# listener, which is issued through the ACME HTTP-01 challenge on its HTTP listener. Like
# the ClusterIssuer it lives in a local chart, because the Gateway API and cert-manager
# custom resources it consists of only exist after the releases above.
resource "helm_release" "gateway" {
  depends_on = [
    helm_release.cilium_lb_config,
    helm_release.step_ca_acme_issuer,
  ]
  name      = local.gateway_name
  chart     = "${path.module}/helm_charts/gateway"
  namespace = kubernetes_namespace_v1.network.id
  timeout   = 60
  values = [
    templatefile("${path.module}/helm_values/gateway.yaml", {
      gateway_name        = local.gateway_name
      gateway_address     = var.cilium_load_balancer_ip_range_start
      http_listener_name  = local.gateway_http_listener_name
      https_listener_name = local.gateway_https_listener_name
      harbor_domain       = var.harbor_domain
      harbor_namespace    = kubernetes_namespace_v1.applications.id
      tls_secret_name     = local.gateway_tls_secret_name
      cluster_issuer_name = local.acme_cluster_issuer_name
    })
  ]
}

resource "helm_release" "harbor" {
  depends_on = [
    kubernetes_secret_v1.docker_hub_namespace_applications,
    kubernetes_storage_class_v1.local,
    kubernetes_persistent_volume_v1.local_large_1,
    kubernetes_persistent_volume_v1.local_small_2,
    kubernetes_persistent_volume_v1.local_small_3,
    kubernetes_persistent_volume_v1.local_small_4,
    kubernetes_persistent_volume_v1.local_small_5,
    helm_release.cilium_lb_config,
    helm_release.gateway,
  ]
  name       = local.harbor_release_name
  chart      = "harbor"
  version    = "1.19.2"
  repository = "https://helm.goharbor.io"
  namespace  = kubernetes_namespace_v1.applications.id
  timeout    = 120
  values = [
    templatefile("${path.module}/helm_values/harbor.yaml", {
      harbor_domain        = var.harbor_domain,
      harbor_url           = var.harbor_url,
      gateway_name         = local.gateway_name,
      gateway_namespace    = kubernetes_namespace_v1.network.id,
      gateway_section_name = local.gateway_https_listener_name
    })
  ]
}

