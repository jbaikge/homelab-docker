resource "docker_image" "databasus" {
  provider     = docker.hosts[var.apps.databasus]
  name         = "databasus/databasus:v3.29.1"
  keep_locally = false
}

resource "docker_volume" "databasus" {
  provider = docker.hosts[var.apps.databasus]
  name     = "databasus"
  driver   = "local"

  driver_opts = {
    type   = "nfs"
    o      = "addr=${var.hosts[var.apps.databasus].nfs_host},rw,nfsvers=4"
    device = ":/mnt/tank/nfs/vols/databasus"
  }
}

resource "docker_container" "databasus" {
  provider = docker.hosts[var.apps.databasus]
  name     = "databasus"
  hostname = "databasus"
  image    = docker_image.databasus.image_id

  env = [
  ]

  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.databasus.rule"
    value = "Host(`databasus.${data.sops_file.secrets.data["domain.tld"]}`)"
  }

  labels {
    label = "traefik.http.routers.databasus.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.routers.databasus.tls"
    value = "true"
  }

  labels {
    label = "traefik.http.services.databasus.loadbalancer.server.port"
    value = "4005"
  }

  volumes {
    container_path = "/etc/localtime"
    host_path      = "/etc/localtime"
    read_only      = true
  }

  volumes {
    container_path = "/databasus-data"
    volume_name    = docker_volume.databasus.name
    read_only      = false
  }
}
