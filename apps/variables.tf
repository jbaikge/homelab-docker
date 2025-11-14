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
  }))
}

variable "service_hosts" {
  description = "Map of services to host keys in the hosts var"

  type = object({
  })
}
