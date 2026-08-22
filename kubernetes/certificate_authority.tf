# Certificate authority
#
# The whole PKI is generated and owned by OpenTofu, so no CLI tooling and no manual
# bootstrap step is needed: `tofu apply` on a fresh clone produces a working CA.
#
# The root CA private key never leaves the OpenTofu state. Only the root certificate,
# the intermediate certificate and the intermediate private key are published to the
# cluster, so compromising the cluster does not allow minting a new intermediate CA.
#
# IMPORTANT: the state file is the only copy of the root CA private key. Back it up and
# keep it confidential. Losing it means a new root CA, which has to be distributed to
# every trust store again.

resource "tls_private_key" "root_ca" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_self_signed_cert" "root_ca" {
  private_key_pem       = tls_private_key.root_ca.private_key_pem
  is_ca_certificate     = true
  set_subject_key_id    = true
  validity_period_hours = var.root_ca_validity_hours

  subject {
    common_name  = "${var.ca_name} Root CA"
    organization = var.ca_name
  }

  allowed_uses = [
    "cert_signing",
    "crl_signing",
    "digital_signature",
  ]
}

resource "tls_private_key" "intermediate_ca" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_cert_request" "intermediate_ca" {
  private_key_pem = tls_private_key.intermediate_ca.private_key_pem

  subject {
    common_name  = "${var.ca_name} Intermediate CA"
    organization = var.ca_name
  }
}

# The intermediate is renewed automatically: once it is within early_renewal_hours of its
# expiry, the next plan replaces it. Renewal is transparent to clients, as they only need
# to trust the root certificate, which stays untouched.
resource "tls_locally_signed_cert" "intermediate_ca" {
  cert_request_pem   = tls_cert_request.intermediate_ca.cert_request_pem
  ca_private_key_pem = tls_private_key.root_ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.root_ca.cert_pem

  is_ca_certificate     = true
  set_subject_key_id    = true
  validity_period_hours = var.intermediate_ca_validity_hours
  early_renewal_hours   = var.intermediate_ca_early_renewal_hours

  allowed_uses = [
    "cert_signing",
    "crl_signing",
    "digital_signature",
  ]
}

locals {
  # Name of the step-certificates Helm release, which is also the name the chart derives
  # its ConfigMaps and Secrets from.
  step_ca_name = "step-certificates"

  step_ca_url = "https://${local.step_ca_name}.${kubernetes_namespace_v1.security.id}.svc.cluster.local"

  # step-ca serves one ACME directory per ACME provisioner, at /acme/<provisioner>/directory.
  step_ca_acme_provisioner   = "acme"
  step_ca_acme_directory_url = "${local.step_ca_url}/acme/${local.step_ca_acme_provisioner}/directory"

  # Name of the cert-manager ClusterIssuer that Certificate resources refer to.
  acme_cluster_issuer_name = "step-ca"

  # step-ca issues its own TLS server certificate for these names.
  step_ca_dns_names = [
    "${local.step_ca_name}.${kubernetes_namespace_v1.security.id}.svc.cluster.local",
    "${local.step_ca_name}.${kubernetes_namespace_v1.security.id}.svc",
    "${local.step_ca_name}.${kubernetes_namespace_v1.security.id}",
    local.step_ca_name,
    "127.0.0.1",
    "localhost",
  ]

  # Equivalent of what `step ca init` would write, but rendered from the resources above.
  # The only provisioner is an ACME provisioner: unlike a JWK provisioner it needs no key
  # material and no password, which is what makes a purely declarative setup possible.
  step_ca_config = {
    root          = "/home/step/certs/root_ca.crt"
    federateRoots = []
    crt           = "/home/step/certs/intermediate_ca.crt"
    key           = "/home/step/secrets/intermediate_ca_key"
    address       = ":9000"
    dnsNames      = local.step_ca_dns_names
    logger        = { format = "json" }
    db = {
      type       = "badgerv2"
      dataSource = "/home/step/db"
    }
    authority = {
      enableAdmin = false
      claims = {
        minTLSCertDuration     = "5m"
        defaultTLSCertDuration = var.certificate_default_duration
        maxTLSCertDuration     = var.certificate_max_duration
        disableRenewal         = false
      }
      provisioners = [
        {
          type    = "ACME"
          name    = local.step_ca_acme_provisioner
          forceCN = true
        }
      ]
    }
    tls = {
      cipherSuites = [
        "TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256",
        "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256",
      ]
      minVersion    = 1.2
      maxVersion    = 1.3
      renegotiation = false
    }
  }

  # Changing this value rolls the step-ca pod, so a renewed intermediate is picked up
  # instead of silently staying in the mounted volumes until the next manual restart.
  ca_material_revision = substr(sha256(join("", [
    tls_self_signed_cert.root_ca.cert_pem,
    tls_locally_signed_cert.intermediate_ca.cert_pem,
  ])), 0, 16)
}

# The step-certificates chart is run in `existingSecrets` mode, which means it creates
# neither key material nor configuration and consumes the three resources below instead.
resource "kubernetes_config_map_v1" "step_certificates_certs" {
  metadata {
    name      = "${local.step_ca_name}-certs"
    namespace = kubernetes_namespace_v1.security.id
  }
  data = {
    "root_ca.crt"         = tls_self_signed_cert.root_ca.cert_pem
    "intermediate_ca.crt" = tls_locally_signed_cert.intermediate_ca.cert_pem
  }
}

resource "kubernetes_config_map_v1" "step_certificates_config" {
  metadata {
    name      = "${local.step_ca_name}-config"
    namespace = kubernetes_namespace_v1.security.id
  }
  data = {
    "ca.json" = jsonencode(local.step_ca_config)
    "defaults.json" = jsonencode({
      "ca-url"    = local.step_ca_url
      "ca-config" = "/home/step/config/ca.json"
      "root"      = "/home/step/certs/root_ca.crt"
    })
  }
}

# step-ca is started without --password-file, so the intermediate key is stored
# unencrypted. It is protected by the Secret rather than by a passphrase that would have
# to be stored next to it anyway.
resource "kubernetes_secret_v1" "step_certificates_secrets" {
  metadata {
    name      = "${local.step_ca_name}-secrets"
    namespace = kubernetes_namespace_v1.security.id
  }
  data = {
    "intermediate_ca_key" = tls_private_key.intermediate_ca.private_key_pem
  }
}
