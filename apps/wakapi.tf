resource "docker_image" "wakapi" {
  provider     = docker.hosts[var.apps.wakapi]
  name         = "ghcr.io/muety/wakapi:2.17.2"
  keep_locally = false
}

resource "docker_volume" "wakapi" {
  provider = docker.hosts[var.apps.wakapi]
  name     = "wakapi"
  driver   = "local"

  driver_opts = {
    type   = "nfs"
    o      = "addr=${var.hosts[var.apps.wakapi].nfs_host},hard,timeo=10,retry=10,vers=4.1"
    device = ":/mnt/tank/nfs/vols/wakapi"
  }
}

resource "docker_container" "wakapi" {
  provider = docker.hosts[var.apps.wakapi]
  name     = "wakapi"
  image    = docker_image.wakapi.image_id

  env = [
    "WAKAPI_PASSWORD_SALT=${data.sops_file.secrets.data["wakapi.password_salt"]}",
    "WAKAPI_PUBLIC_URL=https://waka.${data.sops_file.secrets.data["domain.tld"]}",
    "WAKAPI_EXPOSE_METRICS=true",
  ]

  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.wakapi.rule"
    value = "Host(`waka.${data.sops_file.secrets.data["domain.tld"]}`)"
  }

  labels {
    label = "traefik.http.routers.wakapi.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.routers.wakapi.tls"
    value = "true"
  }

  labels {
    label = "traefik.http.services.wakapi.loadbalancer.server.port"
    value = "3000"
  }

  volumes {
    container_path = "/data"
    volume_name    = docker_volume.wakapi.name
    read_only      = false
  }

  volumes {
    container_path = "/etc/localtime"
    host_path      = "/etc/localtime"
    read_only      = true
  }
}
