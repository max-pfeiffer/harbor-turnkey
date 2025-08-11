resource "harbor_registry" "docker_hub" {
  depends_on    = [helm_release.harbor]
  provider_name = "docker-hub"
  name          = "Docker Hub"
  endpoint_url  = "https://hub.docker.com"
  access_id     = var.docker_hub_username
  access_secret = var.docker_hub_password
}

resource "harbor_registry" "github" {
  depends_on    = [helm_release.harbor]
  provider_name = "github"
  name          = "GitHub"
  endpoint_url  = "https://ghcr.io"
  access_id     = var.github_username
  access_secret = var.github_password
}

resource "harbor_project" "docker_hub" {
  name        = "docker-hub-cache"
  public      = true
  registry_id = harbor_registry.docker_hub.registry_id
}

resource "harbor_project" "github" {
  name        = "github-cache"
  public      = true
  registry_id = harbor_registry.github.registry_id
}