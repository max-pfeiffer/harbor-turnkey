resource "helm_release" "cilium_lb_config" {
  name       = "cilium-lb-config"
  chart      = "${path.module}/helm_charts/cilium-lb-config"
  timeout    = 60
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
  ]
  name       = "step-certificates"
  chart      = "step-certificates"
  version    = "1.29.0"
  repository = "https://smallstep.github.io/helm-charts/"
  namespace  = kubernetes_namespace_v1.security.id
  timeout    = 120
  values = [
    file("${path.module}/helm_values/step-certificates-bootstrap.yaml"),
    templatefile("${path.module}/helm_values/step-certificates.yaml", {
      root_ca_password = base64encode(var.root_ca_password)
    })
  ]
}

data "kubernetes_config_map_v1" "step_certificates_certs" {
  depends_on = [helm_release.step_certificates]
  metadata {
    name      = "step-certificates-certs"
    namespace = "security"
  }
}

data "kubernetes_config_map_v1" "step_certificates_config" {
  depends_on = [helm_release.step_certificates]
  metadata {
    name      = "step-certificates-config"
    namespace = "security"
  }
}

resource "helm_release" "step_issuer" {
  depends_on = [
    kubernetes_secret_v1.docker_hub_namespace_security,
    helm_release.step_certificates,
    data.kubernetes_config_map_v1.step_certificates_certs,
    data.kubernetes_config_map_v1.step_certificates_config
  ]
  name       = "step-issuer"
  chart      = "step-issuer"
  version    = "1.9.11"
  repository = "https://smallstep.github.io/helm-charts/"
  namespace  = kubernetes_namespace_v1.security.id
  timeout    = 120
  values = [
    templatefile("${path.module}/helm_values/step-issuer.yaml", {
      ca_url                            = jsondecode(data.kubernetes_config_map_v1.step_certificates_config.data["defaults.json"]).ca-url
      ca_bundle                         = base64encode(data.kubernetes_config_map_v1.step_certificates_certs.data["root_ca.crt"])
      provisioner_name                  = jsondecode(data.kubernetes_config_map_v1.step_certificates_config.data["ca.json"]).authority.provisioners[0].name
      provisioner_kid                   = jsondecode(data.kubernetes_config_map_v1.step_certificates_config.data["ca.json"]).authority.provisioners[0].key.kid
      provisioner_passwordref_name      = "step-certificates-provisioner-password"
      provisioner_passwordref_key       = "password"
      provisioner_passwordref_namespace = kubernetes_namespace_v1.security.id
    })
  ]
}

resource "helm_release" "cert_manager" {
  depends_on = [
    kubernetes_secret_v1.docker_hub_namespace_cert_manager,
    helm_release.step_certificates,
    helm_release.step_issuer
  ]
  name       = "cert-manager"
  chart      = "cert-manager"
  version    = "1.19.2"
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
  ]
  name       = "harbor"
  chart      = "harbor"
  version    = "1.18.1"
  repository = "https://helm.goharbor.io"
  namespace  = kubernetes_namespace_v1.applications.id
  timeout    = 120
  values = [
    templatefile("${path.module}/helm_values/harbor.yaml", {
      harbor_domain = var.harbor_domain,
      harbor_url    = var.harbor_url
    })
  ]
}

