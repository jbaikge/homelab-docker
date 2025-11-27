variable "backend" {
  description = "Configuration values for CloudFlare S3 state backend"

  type = object({
    bucket     = string
    key        = string
    endpoint   = string
    access_key = string
    secret_key = string
  })
}

variable "hosts" {
  description = "Map of host short-name to various config options"

  type = map(object({
    provider_host = string
    nfs_host      = string
    service_ip    = string
  }))
}

variable "apps" {
  description = "Map of services to host keys in the hosts var"

  type = object({
    adminer        = string
    bentopdf       = string
    blocky         = list(string)
    cloudflared    = list(string)
    dozzle         = string
    dozzle_agent   = list(string)
    forgejo        = string
    glance         = string
    home_assistant = string
    lego           = list(string)
    linkding       = string
    miniflux       = string
    mysql          = string
    postgres       = string
    prometheus     = string
    redis          = string
    traefik        = list(string)
    unbound        = list(string)
    wakapi         = string
    zwave          = string
  })
}
