resource "docker_image" "forgejo" {
  provider     = docker.hosts[var.apps.forgejo]
  name         = "codeberg.org/forgejo/forgejo:14.0.3"
  keep_locally = false
}

resource "docker_volume" "forgejo" {
  provider = docker.hosts[var.apps.forgejo]
  name     = "forgejo"
  driver   = "local"

  driver_opts = {
    type   = "nfs"
    o      = "addr=${var.hosts[var.apps.forgejo].nfs_host},hard,timeo=10,retry=10,vers=4.1"
    device = ":/mnt/tank/nfs/vols/forgejo"
  }
}

resource "docker_container" "forgejo" {
  provider = docker.hosts[var.apps.forgejo]
  name     = "forgejo"
  image    = docker_image.forgejo.image_id

  env = [
    "USER_UID=1000",
    "USER_GID=1000",
  ]

  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.forgejo_http.rule"
    value = "Host(`git.${data.sops_file.secrets.data["domain.tld"]}`)"
  }

  labels {
    label = "traefik.http.routers.forgejo_http.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.routers.forgejo_http.tls"
    value = "true"
  }

  labels {
    label = "traefik.http.services.forgejo_http.loadbalancer.server.port"
    value = "3000"
  }

  labels {
    label = "traefik.tcp.routers.forgejo_ssh.rule"
    value = "HostSNI(`*`)"
  }

  labels {
    label = "trafeik.tcp.routers.forgejo_ssh.entrypoints"
    value = "ssh"
  }

  labels {
    label = "traefik.tcp.services.forgejo_ssh.loadbalancer.server.port"
    value = "22"
  }

  volumes {
    container_path = "/data"
    volume_name    = docker_volume.forgejo.name
    read_only      = false
  }

  volumes {
    container_path = "/etc/localtime"
    host_path      = "/etc/localtime"
    read_only      = true
  }

  volumes {
    container_path = "/etc/timezone"
    host_path      = "/etc/timezone"
    read_only      = true
  }
}
