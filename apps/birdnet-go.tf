resource "docker_image" "birdnet_go" {
  provider     = docker.hosts[var.apps.birdnet_go]
  name         = "ghcr.io/tphakala/birdnet-go:nightly-20260322"
  keep_locally = false
}

resource "docker_volume" "birdnet_go_config" {
  provider = docker.hosts[var.apps.birdnet_go]
  name     = "birdnet_go_config"
  driver   = "local"

  driver_opts = {
    type   = "nfs"
    o      = "addr=${var.hosts[var.apps.birdnet_go].nfs_host},hard,timeo=10,retry=10,vers=4.1"
    device = ":/mnt/tank/nfs/vols/birdnet_go/config"
  }
}

resource "docker_volume" "birdnet_go_data" {
  provider = docker.hosts[var.apps.birdnet_go]
  name     = "birdnet_go_data"
  driver   = "local"

  driver_opts = {
    type   = "nfs"
    o      = "addr=${var.hosts[var.apps.birdnet_go].nfs_host},hard,timeo=10,retry=10,vers=4.1"
    device = ":/mnt/tank/nfs/vols/birdnet_go/data"
  }
}

resource "docker_container" "birdnet_go" {
  provider = docker.hosts[var.apps.birdnet_go]
  name     = "birdnet_go"
  image    = docker_image.birdnet_go.image_id

  env = [
    "TZ=${data.sops_file.secrets.data["location.timezone"]}",
    "BIRDNET_LATITUDE=${data.sops_file.secrets.data["location.latitude"]}",
    "BIRDNET_LONGITUDE=${data.sops_file.secrets.data["location.longitude"]}",
  ]

  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.birdnetgo.rule"
    value = "Host(`birds.${data.sops_file.secrets.data["domain.tld"]}`)"
  }

  labels {
    label = "traefik.http.routers.birdnetgo.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.routers.birdnetgo.tls"
    value = "true"
  }

  labels {
    label = "traefik.http.services.birdnetgo.loadbalancer.server.port"
    value = "8080"
  }

  volumes {
    container_path = "/config"
    volume_name    = docker_volume.birdnet_go_config.name
    read_only      = false
  }

  volumes {
    container_path = "/data"
    volume_name    = docker_volume.birdnet_go_data.name
    read_only      = false
  }
}
