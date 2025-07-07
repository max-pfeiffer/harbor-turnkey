resource "kubernetes_secret" "docker_hub" {
  metadata {
    namespace = kubernetes_namespace_v1.applications.id
    name      = "docker-registry-secret"
  }
  type = "kubernetes.io/dockerconfigjson"
  data = {
    ".dockerconfigjson" = templatefile("${path.module}/templates/docker_config_json.tftpl", {
      docker-username = var.docker_hub_username
      docker-password = var.docker_hub_password
      docker-server   = "https://index.docker.io/v1/"
      docker-email    = var.docker_hub_email
      auth            = base64encode("${var.docker_hub_username}:${var.docker_hub_password}")
    })
  }
}


resource "kubernetes_secret" "harbor" {
  metadata {
    namespace = kubernetes_namespace_v1.applications.id
    name      = "harbor"
  }
  data = {
    HARBOR_ADMIN_PASSWORD = random_password.harbor_admin_password.result
  }
}
