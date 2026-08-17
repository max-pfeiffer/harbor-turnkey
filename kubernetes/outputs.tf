output "root_ca_crt" {
  description = "Root CA certificate in PEM format. Add it to the trust store of every machine and Kubernetes cluster that talks to this Harbor instance."
  value       = tls_self_signed_cert.root_ca.cert_pem
}

output "intermediate_ca_crt" {
  description = "Intermediate CA certificate in PEM format. Clients do not need it, step-ca serves it as part of the certificate chain."
  value       = tls_locally_signed_cert.intermediate_ca.cert_pem
}

output "step_ca_acme_directory_url" {
  description = "ACME directory of the step-ca ACME provisioner, for issuing certificates to other in-cluster workloads."
  value       = local.step_ca_acme_directory_url
}
