resource "docker_image" "librespeed" {
  provider     = docker.hosts[var.apps.librespeed]
  name         = "ghcr.io/librespeed/speedtest:5.5.1"
  keep_locally = false
}

resource "docker_container" "librespeed" {
  provider = docker.hosts[var.apps.librespeed]
  name     = "librespeed"
  image    = docker_image.librespeed.image_id

  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.librespeed.rule"
    value = "Host(`librespeed.${data.sops_file.secrets.data["domain.tld"]}`)"
  }

  labels {
    label = "traefik.http.routers.librespeed.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.routers.librespeed.tls"
    value = "true"
  }

  labels {
    label = "traefik.http.services.librespeed.loadbalancer.server.port"
    value = "8080"
  }

  ports {
    internal = 8080
    external = 16384
    ip       = var.hosts[var.apps.librespeed].service_ip
    protocol = "tcp"
  }
}
