resource "docker_network" "paperless" {
  provider = docker.hosts[var.apps.paperless_ngx]
  name     = "paperless"
}
