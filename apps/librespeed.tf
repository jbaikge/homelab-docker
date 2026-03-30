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

  labels {
    label = "traefik.http.routers.librespeed.middlewares"
    value = "limit"
  }

  labels {
    label = "traefik.http.middlewares.limit.buffering.maxRequestBodyBytes"
    value = "10000000000"
  }
}
