resource "docker_image" "dozzle_agent" {
  for_each     = toset(var.apps.dozzle_agent)
  provider     = docker.hosts[each.key]
  name         = "ghcr.io/amir20/dozzle:v8.14.8"
  keep_locally = false
}

resource "docker_container" "dozzle_agent" {
  for_each = toset(var.apps.dozzle_agent)
  provider = docker.hosts[each.key]
  name     = "dozzle_agent"
  image    = docker_image.dozzle_agent[each.key].image_id

  command = [
    "agent",
  ]

  ports {
    internal = 7007
    external = 7007
    ip       = var.hosts[each.key].service_ip
    protocol = "tcp"
  }

  volumes {
    container_path = "/etc/localtime"
    host_path      = "/etc/localtime"
    read_only      = true
  }

  volumes {
    container_path = "/var/run/docker.sock"
    host_path      = "/var/run/docker.sock"
    read_only      = true
  }
}
