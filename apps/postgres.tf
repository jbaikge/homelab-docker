resource "docker_image" "postgres" {
  provider     = docker.hosts[var.apps.postgres]
  name         = "postgres:18.1"
  keep_locally = false
}

resource "docker_volume" "postgres" {
  provider = docker.hosts[var.apps.postgres]
  name     = "postgres"
  driver   = "local"

  driver_opts = {
    type   = "nfs"
    o      = "addr=${var.hosts[var.apps.postgres].nfs_host},defaults,nfsvers=4,suid,rw,timeo=600,retrans=2,hard,fg,rsize=8192,wsize=8192,noatime,acregmin=0,acregmax=0,acdirmin=0,acdirmax=0"
    device = ":/mnt/tank/nfs/vols/postgres"
  }
}

resource "docker_container" "postgres" {
  provider = docker.hosts[var.apps.postgres]
  name     = "postgres"
  hostname = "postgres"
  image    = docker_image.postgres.image_id

  env = [
    "POSTGRES_PASSWORD=${sops_file.secrets.data["postgres.password"]}",
  ]

  networks_advanced {
    name = docker_network.database.id
  }

  ports {
    internal = 5432
    external = 5432
    ip       = var.hosts[var.apps.postgres].service_ip
    protocol = "tcp"
  }

  volumes {
    container_path = "/var/lib/postgresql"
    volume_name    = docker_volume.postgres.name
    read_only      = false
  }
}
