resource "docker_image" "linkding" {
  provider     = docker.hosts[var.apps.linkding]
  name         = "ghcr.io/sissbruecker/linkding:1.44.1-plus"
  keep_locally = false
}

resource "docker_volume" "linkding" {
  provider = docker.hosts[var.apps.linkding]
  name     = "linkding"
  driver   = "local"

  driver_opts = {
    type   = "nfs"
    o      = "addr=${var.hosts[var.apps.linkding].nfs_host},rw,nfsvers=4"
    device = ":/mnt/tank/nfs/vols/linkding"
  }
}

resource "docker_container" "linkding" {
  provider = docker.hosts[var.apps.linkding]
  name     = "linkding"
  image    = docker_image.linkding.image_id

  env = [
  ]

  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.linkding.rule"
    value = "Host(`bookmarks.${data.sops_file.secrets.data["domain.tld"]}`)"
  }

  labels {
    label = "traefik.http.routers.linkding.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.routers.linkding.tls"
    value = "true"
  }

  labels {
    label = "traefik.http.services.linkding.loadbalancer.server.port"
    value = "9090"
  }

  volumes {
    container_path = "/etc/localtime"
    host_path      = "/etc/localtime"
    read_only      = true
  }

  volumes {
    container_path = "/etc/linkding/data"
    volume_name    = docker_volume.linkding.name
    read_only      = false
  }
}
