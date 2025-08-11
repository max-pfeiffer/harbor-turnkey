output "root_ca_crt" {
  value     = data.kubernetes_config_map.step_certificates_certs.data["root_ca.crt"]
  sensitive = true
}
