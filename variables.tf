## IWO Collector Variables ##
variable "iwo" {
  type = object({
    enabled                 = bool
    namespace               = string
    cluster_name            = string
    chart_url               = string
    release_name            = optional(string)
    server_version          = optional(string)
    collector_image_version = optional(string)
    dc_image_version        = optional(string)
    })
}

## AppD Agent Variables ##
variable "appd" {
  type = object({
    enabled = bool
    kubernetes = object({
      namespace     = string
      release_name  = optional(string)
      repository    = optional(string)
      chart_name    = optional(string)
      imageinfo     = object({
        imagepullpolicy = optional(string)
        clusteragent    = object({
          image = optional(string)
          tag   = optional(string)
          })
        operator        = optional(object({
          image = optional(string)
          tag   = optional(string)
          }))
        machineagent    = optional(object({
          image = optional(string)
          tag   = optional(string)
          }))
        machineagentwin = optional(object({
          image = optional(string)
          tag   = optional(string)
          }))
        netviz          = optional(object({
          image = optional(string)
          tag   = optional(string)
          }))
        })
      })
    account = object({
      url            = optional(string)
      name           = string
      key            = string
      otel_api_key   = optional(string)
      username       = optional(string)
      password       = optional(string)
      global_account = optional(string)
    })
    metrics_server = object({
      install_service = bool
      release_name    = optional(string)
      repository      = optional(string)
      chart_name      = optional(string)
      })
    machine_agent = object({
      install_service = bool
      infraviz = optional(object({
        enable_container_hostid = optional(bool)
        enable_dockerviz        = optional(bool)
        enable_serverviz        = optional(bool)
        enable_masters          = optional(bool)
        stdout_logging          = optional(bool)
        }))
      netviz = optional(object({
        enabled = optional(bool)
        port    = optional(number)
        }))
      })
    cluster_agent = object({
      install_service           = bool
      app_name                  = optional(string)
      monitor_namespace_regex  = optional(string)
      })
    autoinstrument = object({
      enabled           = bool
      namespace_regex   = optional(string)
      default_appname   = optional(string)
      appname_strategy  = optional(string)
      java = optional(object({
        enabled         = optional(bool)
        runasuser       = optional(number)
        image           = optional(string)
        imagepullpolicy = optional(string)
        }))
      dotnetcore = optional(object({
        enabled         = optional(bool)
        runasuser       = optional(number)
        image           = optional(string)
        imagepullpolicy = optional(string)
        }))
      nodejs = optional(object({
        enabled         = optional(bool)
        runasuser       = optional(number)
        image           = optional(string)
        imagepullpolicy = optional(string)
        }))
      })
    })

  default = {
    enabled = true
    kubernetes = {
      namespace = ""
      imageinfo = {
        clusteragent = {}
        operator = {}
        machineagent = {}
        machineagentwin = {}
        netviz = {}
        }
    }
    account = {
      name = ""
      key  = ""
    }
    metrics_server = {
      install_service = true
      }
    machine_agent = {
      install_service = false
      infraviz = {}
      netviz = {}
      }
    cluster_agent = {
      install_service = true
      }
    autoinstrument = {
      enabled           = false
      java = {}
      dotnetcore = {}
      nodejs = {}
      }
    }
}
