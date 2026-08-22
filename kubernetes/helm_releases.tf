locals {
  harbor_release_name = "harbor"
  # Name of the Ingress the Harbor chart creates. ACME HTTP-01 challenge routes are
  # inserted into it, so it has to be known before the release exists.
  harbor_ingress_name = "${local.harbor_release_name}-ingress"
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
      cluster_issuer_name = local.acme_cluster_issuer_name
      acme_directory_url  = local.step_ca_acme_directory_url
      ca_bundle           = base64encode(tls_self_signed_cert.root_ca.cert_pem)
      solver_ingress_name = local.harbor_ingress_name
    })
  ]
}

resource "helm_release" "harbor" {
  depends_on = [
    kubernetes_secret_v1.docker_hub_namespace_applications,
    helm_release.step_ca_acme_issuer,
    kubernetes_storage_class_v1.local,
    kubernetes_persistent_volume_v1.local_large_1,
    kubernetes_persistent_volume_v1.local_small_2,
    kubernetes_persistent_volume_v1.local_small_3,
    kubernetes_persistent_volume_v1.local_small_4,
    kubernetes_persistent_volume_v1.local_small_5,
    helm_release.cilium_lb_config,
  ]
  name       = local.harbor_release_name
  chart      = "harbor"
  version    = "1.19.2"
  repository = "https://helm.goharbor.io"
  namespace  = kubernetes_namespace_v1.applications.id
  timeout    = 120
  values = [
    templatefile("${path.module}/helm_values/harbor.yaml", {
      harbor_domain       = var.harbor_domain,
      harbor_url          = var.harbor_url,
      cluster_issuer_name = local.acme_cluster_issuer_name
    })
  ]
}

