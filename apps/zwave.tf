resource "docker_image" "zwave" {
  provider     = docker.hosts[var.apps.zwave]
  name         = "zwavejs/zwave-js-ui:11.7.0"
  keep_locally = false
}

resource "docker_volume" "zwave" {
  provider = docker.hosts[var.apps.zwave]
  name     = "zwave"
  driver   = "local"

  driver_opts = {
    type   = "nfs"
    o      = "addr=${var.hosts[var.apps.zwave].nfs_host},rw,nfsvers=4"
    device = ":/mnt/tank/nfs/vols/zwave"
  }
}

resource "docker_container" "zwave" {
  provider = docker.hosts[var.apps.zwave]
  name     = "zwave"
  hostname = "zwave"
  image    = docker_image.zwave.image_id

  env = [
    "TZ=${data.sops_file.secrets.data["location.timezone"]}",
  ]

  devices {
    host_path      = "/dev/serial/by-id/usb-1a86_USB_Single_Serial_58E3038049-if00"
    container_path = "/dev/zwave"
    permissions    = "rwm"
  }

  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.zwave.rule"
    value = "Host(`zwave.${data.sops_file.secrets.data["domain.tld"]}`)"
  }

  labels {
    label = "traefik.http.routers.zwave.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.routers.zwave.tls"
    value = "true"
  }

  labels {
    label = "traefik.http.services.zwave.loadbalancer.server.port"
    value = "8091"
  }

  networks_advanced {
    name = docker_network.home_assistant.id
  }

  volumes {
    container_path = "/usr/src/app/store"
    volume_name    = docker_volume.zwave.name
    read_only      = false
  }
}
