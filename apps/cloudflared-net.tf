resource "docker_network" "cloudflared" {
  for_each = toset(var.apps.cloudflared)
  provider = docker.hosts[each.key]
  name     = "cloudflared"
}
