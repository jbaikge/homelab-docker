resource "docker_network" "home_assistant" {
  provider = docker.hosts[var.apps.home_assistant]
  name     = "home_assistant"
}
