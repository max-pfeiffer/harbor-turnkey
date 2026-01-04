output "root_ca_crt" {
  value     = data.kubernetes_config_map_v1.step_certificates_certs.data["root_ca.crt"]
  sensitive = true
}
