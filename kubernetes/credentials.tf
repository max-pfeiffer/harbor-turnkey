resource "random_password" "harbor_admin_password" {
  length      = 16
  special     = true
  min_lower   = 3
  min_upper   = 3
  min_numeric = 3
  min_special = 3
}
