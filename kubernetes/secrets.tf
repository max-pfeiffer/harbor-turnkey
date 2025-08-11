resource "kubernetes_secret_v1" "docker_hub_namespace_security" {
  metadata {
    namespace = kubernetes_namespace_v1.security.id
    name      = "docker-hub"
  }
  type = "kubernetes.io/dockerconfigjson"
  data = {
    ".dockerconfigjson" = templatefile("${path.module}/templates/docker_config_json.tftpl", {
      docker-username = "${var.docker_hub_username}"
      docker-password = "${var.docker_hub_password}"
      docker-server   = "https://index.docker.io/v1/"
      docker-email    = "${var.docker_hub_email}"
      auth            = base64encode("${var.docker_hub_username}:${var.docker_hub_password}")
    })
  }
}

resource "kubernetes_secret_v1" "docker_hub_namespace_cert_manager" {
  metadata {
    namespace = kubernetes_namespace_v1.cert_manager.id
    name      = "docker-hub"
  }
  type = "kubernetes.io/dockerconfigjson"
  data = {
    ".dockerconfigjson" = templatefile("${path.module}/templates/docker_config_json.tftpl", {
      docker-username = "${var.docker_hub_username}"
      docker-password = "${var.docker_hub_password}"
      docker-server   = "https://index.docker.io/v1/"
      docker-email    = "${var.docker_hub_email}"
      auth            = base64encode("${var.docker_hub_username}:${var.docker_hub_password}")
    })
  }
}

resource "kubernetes_secret_v1" "docker_hub_namespace_ingress" {
  metadata {
    namespace = kubernetes_namespace_v1.ingress.id
    name      = "docker-hub"
  }
  type = "kubernetes.io/dockerconfigjson"
  data = {
    ".dockerconfigjson" = templatefile("${path.module}/templates/docker_config_json.tftpl", {
      docker-username = "${var.docker_hub_username}"
      docker-password = "${var.docker_hub_password}"
      docker-server   = "https://index.docker.io/v1/"
      docker-email    = "${var.docker_hub_email}"
      auth            = base64encode("${var.docker_hub_username}:${var.docker_hub_password}")
    })
  }
}

resource "kubernetes_secret_v1" "docker_hub_namespace_applications" {
  metadata {
    namespace = kubernetes_namespace_v1.applications.id
    name      = "docker-registry-secret"
  }
  type = "kubernetes.io/dockerconfigjson"
  data = {
    ".dockerconfigjson" = templatefile("${path.module}/templates/docker_config_json.tftpl", {
      docker-username = "${var.docker_hub_username}"
      docker-password = "${var.docker_hub_password}"
      docker-server   = "https://index.docker.io/v1/"
      docker-email    = "${var.docker_hub_email}"
      auth            = base64encode("${var.docker_hub_username}:${var.docker_hub_password}")
    })
  }
}

resource "kubernetes_secret_v1" "harbor" {
  metadata {
    namespace = kubernetes_namespace_v1.applications.id
    name      = "harbor-admin"
  }
  data = {
    HARBOR_ADMIN_PASSWORD = var.harbor_admin_password
  }
}
