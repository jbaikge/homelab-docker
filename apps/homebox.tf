resource "docker_image" "homebox" {
  provider     = docker.hosts[var.apps.homebox]
  name         = "ghcr.io/sysadminsmedia/homebox:0.24.2"
  keep_locally = false
}

resource "docker_volume" "homebox" {
  provider = docker.hosts[var.apps.homebox]
  name     = "homebox"
  driver   = "local"

  driver_opts = {
    type   = "nfs"
    o      = "addr=${var.hosts[var.apps.homebox].nfs_host},rw,nfsvers=4"
    device = ":/mnt/tank/nfs/vols/homebox"
  }
}

resource "docker_container" "homebox" {
  provider = docker.hosts[var.apps.homebox]
  name     = "homebox"
  hostname = "homebox"
  image    = docker_image.homebox.image_id

  env = [
  ]

  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.homebox.rule"
    value = "Host(`homebox.${data.sops_file.secrets.data["domain.tld"]}`)"
  }

  labels {
    label = "traefik.http.routers.homebox.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.routers.homebox.tls"
    value = "true"
  }

  labels {
    label = "traefik.http.services.homebox.loadbalancer.server.port"
    value = "7745"
  }

  volumes {
    container_path = "/etc/localtime"
    host_path      = "/etc/localtime"
    read_only      = true
  }

  volumes {
    container_path = "/data"
    volume_name    = docker_volume.homebox.name
    read_only      = false
  }
}
