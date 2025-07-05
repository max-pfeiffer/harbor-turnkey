output "harbor_admin_password" {
  value     = random_password.harbor_admin_password.result
  sensitive = true
}
