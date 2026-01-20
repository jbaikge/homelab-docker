resource "docker_image" "home_assistant" {
  provider     = docker.hosts[var.apps.home_assistant]
  name         = "ghcr.io/home-assistant/home-assistant:2026.1.2"
  keep_locally = false
}

resource "docker_volume" "home_assistant_config" {
  provider = docker.hosts[var.apps.home_assistant]
  name     = "home-assistant"
  driver   = "local"

  driver_opts = {
    type   = "nfs"
    o      = "addr=${var.hosts[var.apps.home_assistant].nfs_host},rw,nfsvers=4"
    device = ":/mnt/tank/nfs/vols/home-assistant"
  }
}

resource "docker_container" "home_assistant" {
  provider = docker.hosts[var.apps.home_assistant]
  name     = "home-assistant"
  hostname = "home-assistant"
  image    = docker_image.home_assistant.image_id

  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.home_assistant.rule"
    value = "Host(`home.${data.sops_file.secrets.data["domain.tld"]}`)"
  }

  labels {
    label = "traefik.http.routers.home_assistant.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.routers.home_assistant.tls"
    value = "true"
  }

  labels {
    label = "traefik.http.services.home_assistant.loadbalancer.server.port"
    value = "8123"
  }

  networks_advanced {
    name = docker_network.home_assistant.id
  }

  networks_advanced {
    name = docker_network.cloudflared[var.apps.home_assistant].id
  }

  volumes {
    container_path = "/config"
    volume_name    = docker_volume.home_assistant_config.name
    read_only      = false
  }

  volumes {
    container_path = "/etc/localtime"
    host_path      = "/etc/localtime"
    read_only      = true
  }
}
