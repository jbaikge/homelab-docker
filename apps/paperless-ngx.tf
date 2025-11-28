locals {
  paperless_ngx = {
    volumes = [
      "consume",
      "data",
      "exports",
      "media",
    ]
  }
}

resource "docker_image" "paperless_ngx" {
  provider     = docker.hosts[var.apps.paperless_ngx]
  name         = "ghcr.io/paperless-ngx/paperless-ngx:2.20.0"
  keep_locally = false
}

resource "docker_volume" "paperless_ngx" {
  provider = docker.hosts[var.apps.paperless_ngx]
  for_each = toset(local.paperless_ngx.volumes)
  name     = "paperless-ngx-${each.key}"
  driver   = "local"

  driver_opts = {
    type   = "nfs"
    o      = "addr=${var.hosts[var.apps.paperless_ngx].nfs_host},hard,timeo=10,retry=10,vers=4.1"
    device = ":/mnt/tank/nfs/vols/paperless/${each.key}"
  }
}
