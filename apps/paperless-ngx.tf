locals {
  paperless_ngx = {
    version = "2.20.9"
    volumes = [
      "consume",
      "data",
      "export",
      "media",
    ]
  }
}

resource "docker_image" "paperless_ngx" {
  provider     = docker.hosts[var.apps.paperless_ngx]
  name         = "ghcr.io/paperless-ngx/paperless-ngx:${local.paperless_ngx.version}"
  keep_locally = false
}

resource "docker_volume" "paperless_ngx" {
  provider = docker.hosts[var.apps.paperless_ngx]
  for_each = toset(local.paperless_ngx.volumes)
  name     = "paperless-ngx-${each.key}"
  driver   = "local"

  driver_opts = {
    type   = "nfs"
    o      = "addr=${var.hosts[var.apps.paperless_ngx].nfs_host},vers=4.1,nolock,soft"
    device = ":/mnt/tank/nfs/vols/paperless/${each.key}"
  }
}

resource "docker_container" "paperless_ngx" {
  provider = docker.hosts[var.apps.paperless_ngx]
  name     = "paperless-ngx"
  image    = docker_image.paperless_ngx.image_id

  env = [
    "PAPERLESS_ADMIN_PASSWORD=${data.sops_file.secrets.data["paperless.admin.password"]}",
    "PAPERLESS_ADMIN_USER=${data.sops_file.secrets.data["paperless.admin.username"]}",
    # "PAPERLESS_CONSUMPTION_DIR=/srv/consume",
    # "PAPERLESS_DATA_DIR=/srv/data",
    "PAPERLESS_DATE_ORDER=MDY",
    "PAPERLESS_DBHOST=${var.hosts[var.apps.postgres].service_ip}",
    "PAPERLESS_DBNAME=${data.sops_file.secrets.data["paperless.db.database"]}",
    "PAPERLESS_DBPASS=${data.sops_file.secrets.data["paperless.db.password"]}",
    "PAPERLESS_DBUSER=${data.sops_file.secrets.data["paperless.db.username"]}",
    # "PAPERLESS_MEDIA_ROOT=/srv/media",
    "PAPERLESS_OCR_USER_ARGS={\"continue_on_soft_render_error\": true}",
    "PAPERLESS_REDIS=redis://${var.hosts[var.apps.redis].service_ip}:6379",
    "PAPERLESS_REDIS_PREFIX=paperless",
    "PAPERLESS_TIKA_ENABLED=1",
    "PAPERLESS_TIKA_ENDPOINT=http://tika:9998",
    "PAPERLESS_TIKA_GOTENBERG_ENDPOINT=http://gotenberg:3000",
    "PAPERLESS_TIME_ZONE=${data.sops_file.secrets.data["location.timezone"]}",
    "PAPERLESS_URL=https://docs.${data.sops_file.secrets.data["domain.tld"]}",
    "USERMAP_GID=1000",
    "USERMAP_UID=1000",
  ]

  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.paperless.rule"
    value = "Host(`docs.${data.sops_file.secrets.data["domain.tld"]}`)"
  }

  labels {
    label = "traefik.http.routers.paperless.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.routers.paperless.tls"
    value = "true"
  }

  labels {
    label = "traefik.http.services.paperless.loadbalancer.server.port"
    value = "8000"
  }

  dynamic "volumes" {
    for_each = toset(local.paperless_ngx.volumes)
    content {
      container_path = "/usr/src/paperless/${volumes.key}"
      volume_name    = docker_volume.paperless_ngx[volumes.key].name
      read_only      = false
    }
  }

  volumes {
    container_path = "/etc/localtime"
    host_path      = "/etc/localtime"
    read_only      = true
  }
}
