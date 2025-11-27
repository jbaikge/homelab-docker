resource "docker_image" "redis" {
  provider     = docker.hosts[var.apps.redis]
  name         = "redis:8.4.0"
  keep_locally = false
}

resource "docker_volume" "redis" {
  provider = docker.hosts[var.apps.redis]
  name     = "redis"
  driver   = "local"

  driver_opts = {
    type   = "nfs"
    o      = "addr=${var.hosts[var.apps.redis].nfs_host},hard,timeo=10,retry=10,vers=4.1"
    device = ":/mnt/tank/nfs/vols/redis"
  }
}

resource "docker_container" "redis" {
  provider = docker.hosts[var.apps.redis]
  name     = "redis"
  hostname = "redis"
  image    = docker_image.redis.image_id

  networks_advanced {
    name = docker_network.database.id
  }

  ports {
    internal = 6379
    external = 6379
    ip       = var.hosts[var.apps.redis].service_ip
    protocol = "tcp"
  }

  volumes {
    container_path = "/etc/localtime"
    host_path      = "/etc/localtime"
    read_only      = true
  }

  volumes {
    container_path = "/data"
    volume_name    = docker_volume.redis.name
    read_only      = false
  }
}

