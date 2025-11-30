resource "docker_image" "sftp" {
  provider     = docker.hosts[var.apps.sftp]
  name         = "ghcr.io/atmoz/sftp/debian:latest"
  keep_locally = false

  pull_triggers = [
    "sha256:9ec84490ab6c9681cb99347009373514acddd592594e21718f84a33eab8f3ca9",
  ]
}

resource "docker_container" "sftp" {
  provider = docker.hosts[var.apps.sftp]
  name     = "sftp"
  image    = docker_image.sftp.image_id

  command = [
    data.sops_file.secrets.data["sftp.users.scanner"],
  ]

  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.tcp.routers.sftp.rule"
    value = "HostSNI(`*`)"
  }

  labels {
    label = "traefik.tcp.routers.sftp.entrypoints"
    value = "ssh"
  }

  labels {
    label = "traefik.tcp.services.sftp.loadbalancer.server.port"
    value = "22"
  }

  upload {
    file    = "/etc/ssh/ssh_host_ed25519_key"
    content = data.sops_file.secrets.data["sftp.host_keys.ed25519"]
  }

  upload {
    file    = "/etc/ssh/ssh_host_rsa_key"
    content = data.sops_file.secrets.data["sftp.host_keys.rsa"]
  }

  upload {
    file    = "/home/scanner/.ssh/keys/id_rsa.pub"
    content = data.sops_file.secrets.data["sftp.user_keys.scanner"]
  }

  volumes {
    container_path = "/home/scanner/upload"
    volume_name    = docker_volume.paperless_ngx["consume"].name
    read_only      = false
  }
}
