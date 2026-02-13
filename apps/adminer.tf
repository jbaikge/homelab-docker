resource "docker_image" "adminer" {
  provider     = docker.hosts[var.apps.adminer]
  name         = "adminer:5.4.2"
  keep_locally = false
}

resource "docker_container" "adminer" {
  provider = docker.hosts[var.apps.adminer]
  name     = "adminer"
  image    = docker_image.adminer.image_id

  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.adminer.rule"
    value = "Host(`db.${data.sops_file.secrets.data["domain.tld"]}`)"
  }

  labels {
    label = "traefik.http.routers.adminer.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.routers.adminer.tls"
    value = "true"
  }

  labels {
    label = "traefik.http.services.adminer.loadbalancer.server.port"
    value = "8080"
  }

  networks_advanced {
    name = docker_network.database.id
  }
}
