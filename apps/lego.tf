resource "docker_image" "lego" {
  for_each     = toset(var.apps.lego)
  provider     = docker.hosts[each.value]
  name         = "goacme/lego:v4.28.1"
  keep_locally = false
}

resource "docker_volume" "certificates" {
  for_each = toset(var.apps.lego)
  provider = docker.hosts[each.value]
  name     = "certificates"
  driver   = "local"

  driver_opts = {
    type   = "nfs"
    o      = "addr=${var.hosts[each.value].nfs_host},rw,nfsvers=4"
    device = ":/mnt/tank/nfs/vols/certificates"
  }
}

# resource "docker_container" "lego" {
#   for_each = toset(var.apps.lego)
#   provider = docker.hosts[each.value]
#   name     = "lego"
#   image    = docker_image.lego[each.key].image_id
#   must_run = false
#   start    = false

#   volumes {
#     container_path = ""
#     volume_name    = docker_volume.certificates[each.key].name
#     read_only      = false
#   }
# }
