resource "docker_image" "traefik" {
  for_each     = toset(var.apps.traefik)
  provider     = docker.hosts[each.key]
  name         = "traefik:v3.6.8"
  keep_locally = false
}

# resource "docker_volume" "traefik_config" {
#   for_each = toset(var.apps.traefik)
#   provider = docker.hosts[each.key]
#   name     = "traefik-config"
#   driver   = "local"

#   driver_opts = {
#     type   = "nfs"
#     o      = "addr=${var.hosts[each.key].nfs_host},rw,nfsvers=4"
#     device = ":/mnt/tank/nfs/vols/traefik-config"
#   }
# }

resource "docker_container" "traefik" {
  for_each = toset(var.apps.traefik)
  provider = docker.hosts[each.key]
  name     = "traefik"
  image    = docker_image.traefik[each.key].image_id

  command = [
    # Entrypoints
    "--entrypoints.ssh.address=:22",
    "--entrypoints.web.address=:80",
    "--entrypoints.web.http.redirections.entrypoint.to=websecure",
    "--entrypoints.web.http.redirections.entrypoint.scheme=https",
    "--entrypoints.web.http.redirections.entrypoint.permanent=true",
    "--entrypoints.websecure.address=:443",
    "--entrypoints.websecure.http.tls=true",

    # Dynamic configuration
    # Watch this directory for changes, when updating the certificates, touch
    # the configuration file(s) inside
    # https://community.traefik.io/t/how-to-renew-update-user-defined-custom-certificates/20598/6
    "--providers.file.directory=/etc/traefik",
    "--providers.file.watch=true",

    # Providers
    "--providers.docker=true",
    "--providers.docker.exposedbydefault=false",
    # "--providers.docker.network=proxy",

    # API & Dashboard
    "--api.dashboard=true",
    "--api.insecure=false",

    # Observability
    "--log.level=INFO",
    "--accesslog=true",
    "--metrics.prometheus=true",
  ]

  # Enable self-routing
  labels {
    label = "traefik.enable"
    value = "true"
  }

  # Dashboard routing
  labels {
    label = "traefik.http.routers.dashboard.rule"
    value = nonsensitive("Host(`${each.key}.${data.sops_file.secrets.data["domain.tld"]}`)")
  }

  labels {
    label = "traefik.http.routers.dashboard.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.routers.dashboard.service"
    value = "api@internal"
  }

  # Basic-auth middleware
  labels {
    label = "traefik.http.middlewares.dashboard-auth.basicauth.users"
    value = nonsensitive(data.sops_file.secrets.data["traefik.users"])
  }

  labels {
    label = "traefik.http.routers.dashboard.middlewares"
    value = "dashboard-auth@docker"
  }

  ports {
    internal = 22
    external = 22
    ip       = var.hosts[each.key].service_ip
    protocol = "tcp"
  }

  ports {
    internal = 80
    external = 80
    ip       = var.hosts[each.key].service_ip
    protocol = "tcp"
  }

  ports {
    internal = 443
    external = 443
    ip       = var.hosts[each.key].service_ip
    protocol = "tcp"
  }

  volumes {
    container_path = "/etc/traefik_certs"
    volume_name    = docker_volume.certificates[each.key].name
    read_only      = true
  }

  # volumes {
  #   container_path = "/etc/traefik"
  #   volume_name    = docker_volume.traefik_config[each.key].name
  #   read_only      = false
  # }

  volumes {
    container_path = "/var/run/docker.sock"
    host_path      = "/var/run/docker.sock"
    read_only      = true
  }

  upload {
    file = "/etc/traefik/traefik-config.yaml"

    content = templatefile("${path.module}/files/traefik-config.yaml", {
      domain = data.sops_file.secrets.data["domain.tld"]
    })
  }
}
