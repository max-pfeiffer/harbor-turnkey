resource "harbor_registry" "main" {
  depends_on = [helm_release.harbor]
  provider_name = "docker-hub"
  name          = "Docker Hub"
  endpoint_url  = "https://hub.docker.com"
  access_id = var.docker_hub_username
  access_secret = var.docker_hub_password
}
