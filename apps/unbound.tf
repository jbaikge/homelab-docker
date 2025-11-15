# TODO figure out how to get this to work later

# resource "docker_image" "unbound" {
#   for_each     = toset(var.apps.unbound)
#   provider     = docker.hosts[each.key]
#   name         = "ghcr.io/klutchell/unbound:v1.24.1"
#   keep_locally = false
# }

# resource "docker_container" "unbound" {
#   for_each = toset(var.apps.unbound)
#   provider = docker.hosts[each.key]
#   name     = "unbound"
#   hostname = "unbound"
#   image    = docker_image.unbound[each.key].image_id

#   ports {
#     internal = 53
#     external = 5335
#     ip       = var.hosts[each.key].service_ip
#     protocol = "udp"
#   }
# }
