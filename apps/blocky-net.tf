resource "docker_network" "blocky" {
  for_each = toset(var.apps.blocky)
  provider = docker.hosts[each.key]
  name     = "blocky"
}
