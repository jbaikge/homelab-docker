resource "docker_network" "database" {
  provider = docker.hosts[var.apps.adminer]
  name     = "database"
}
