## Kubernetes Credential Variables ##
variable "kube_config" {
  type = string
}

## IWO Collector Variables ##
variable "iwo" {
  type = object({
    enabled                 = bool
    namespace               = string
    cluster_name            = string
    chart_url               = string
    server_version          = optional(string)
    collector_image_version = optional(string)
    dc_image_version        = optional(string)
    })
}

variable "appd" {
  type = object({
    enabled = bool
    kubernetes = object({
      namespace = string
      repository = optional(string)
      chart_name = optional(string)
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
    install_metrics_server  = optional(bool)
    install_cluster_agent   = optional(bool)
    install_machine_agents  = optional(bool)
    infraviz = object({
      enable_container_hostid = optional(bool)
      enable_dockerviz        = optional(bool)
      enable_serverviz        = optional(bool)
      enable_masters          = optional(bool)
      stdout_logging          = optional(bool)
      })
    netviz = object({
      enabled = optional(bool)
      })
    cluster = object({
      montior_namespace_regex = optional(string)
      })
    autoinstrument = object({
      enabled           = bool
      namespace_regex   = optional(string)
      default_appname   = optional(string)
      appname_strategy  = optional(string)
      java = object({
        runasuser       = optional(number)
        image           = optional(string)
        imagepullpolicy = optional(string)
        })
      dotnetcore = object({
        runasuser       = optional(number)
        image           = optional(string)
        imagepullpolicy = optional(string)
        })
      nodejs = object({
        runasuser       = optional(number)
        image           = optional(string)
        imagepullpolicy = optional(string)
        })
      imageinfo = object({
        imagepullpolicy = optional(string)
        clusteragent = object({
          image = optional(string)
          tag   = optional(string)
          })
        operator = object({
          image = optional(string)
          tag   = optional(string)
          })
        machineagent = object({
          image = optional(string)
          tag   = optional(string)
          })
        machineagentwin = object({
          image = optional(string)
          tag   = optional(string)
          })
        netviz = object({
          image = optional(string)
          tag   = optional(string)
          })
        })
      })
    })
}
