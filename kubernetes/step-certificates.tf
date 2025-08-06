resource "local_sensitive_file" "root_ca_password" {
  content  = var.root_ca_password
  filename = "${path.module}/step_certificates_config/root_ca_password.txt"
}

resource "terraform_data" "root_ca_certificates" {
  provisioner "local-exec" {
    environment = {
      STEPPATH = "${path.module}/step_certificates_config"
      STEP_PASSWORD_FILE = local_sensitive_file.root_ca_password.filename
      STEP_PROVISIONER_PASSWORD_FILE = local_sensitive_file.root_ca_password.filename
      VALUES_FILE = "${path.module}/step_certificates_config/test.yaml"
    }
    command = <<EOT
      if [ ! -f "$VALUES_FILE" ]; then
        step ca init \
          --name "Harbor" \
          --dns "step-certificates.security.svc.cluster.local" \
          --address ":9000" \
          --provisioner "cert-manager" \
          --deployment-type standalone \
          --helm \
          > $VALUES_FILE
      fi
    EOT
  }
  triggers_replace = {
    file_missing = fileexists("${path.module}/step_certificates_config/test.yaml") ? "exists" : "missing"
  }
}
