resource "docker_image" "prometheus" {
  provider     = docker.hosts[var.apps.prometheus]
  name         = "docker.io/prom/prometheus:v3.8.1"
  keep_locally = false
}

resource "docker_volume" "prometheus" {
  provider = docker.hosts[var.apps.prometheus]
  name     = "prometheus"
  driver   = "local"

  driver_opts = {
    type   = "nfs"
    o      = "addr=${var.hosts[var.apps.prometheus].nfs_host},rw,nfsvers=4"
    device = ":/mnt/tank/nfs/vols/prometheus"
  }
}

resource "docker_container" "prometheus" {
  provider = docker.hosts[var.apps.prometheus]
  name     = "prometheus"
  hostname = "prometheus"
  image    = docker_image.prometheus.image_id

  dns = [
    for host in var.hosts : host.service_ip
  ]

  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.prometheus.rule"
    value = "Host(`prometheus.${data.sops_file.secrets.data["domain.tld"]}`)"
  }

  labels {
    label = "traefik.http.routers.prometheus.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.routers.prometheus.tls"
    value = "true"
  }

  labels {
    label = "traefik.http.services.prometheus.loadbalancer.server.port"
    value = "9090"
  }

  networks_advanced {
    name = docker_network.database.id
  }

  upload {
    file = "/etc/prometheus/prometheus.yml"

    content = templatefile("${path.module}/files/prometheus-config.yaml", {
      home_assistant_token = data.sops_file.secrets.data["prometheus.hass.token"]
      home_assistant_url   = data.sops_file.secrets.data["prometheus.hass.url"]
    })
  }

  volumes {
    container_path = "/etc/localtime"
    host_path      = "/etc/localtime"
    read_only      = true
  }

  volumes {
    container_path = "/prometheus"
    volume_name    = docker_volume.prometheus.name
    read_only      = false
  }
}
