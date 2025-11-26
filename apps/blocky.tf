resource "docker_image" "blocky" {
  for_each     = toset(var.apps.blocky)
  provider     = docker.hosts[each.key]
  name         = "ghcr.io/0xerr0r/blocky:v0.28.1"
  keep_locally = false
}

resource "docker_container" "blocky" {
  for_each = toset(var.apps.blocky)
  provider = docker.hosts[each.key]
  name     = "blocky"
  hostname = "blocky"
  image    = docker_image.blocky[each.key].image_id

  env = [
    "TZ=${data.sops_file.secrets.data["location.timezone"]}",
  ]

  networks_advanced {
    name = docker_network.blocky[each.key].id
  }

  ports {
    internal = 53
    external = 53
    ip       = var.hosts[each.key].service_ip
    protocol = "tcp"
  }

  ports {
    internal = 53
    external = 53
    ip       = var.hosts[each.key].service_ip
    protocol = "udp"
  }

  upload {
    file = "/app/config.yml"

    content = templatefile("${path.module}/files/blocky-config.yaml", {
      domain     = data.sops_file.secrets.data["domain.tld"]
      ash_ip     = var.hosts["ash"].service_ip
      cherry_ip  = var.hosts["cherry"].service_ip
      hickory_ip = var.hosts["hickory"].service_ip
      maple_ip   = var.hosts["maple"].service_ip
    })
  }

  volumes {
    container_path = "/etc/localtime"
    host_path      = "/etc/localtime"
    read_only      = true
  }

  depends_on = [
    docker_container.unbound,
  ]
}
