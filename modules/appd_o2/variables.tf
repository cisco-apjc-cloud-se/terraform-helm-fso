## AppD O2 Operator Variables ##
variable "appd_o2" {
  type = object({
    enabled = bool
    operator = object({
      enabled = bool
      helm = optional(object({
        version       = optional(string)
        release_name  = optional(string)
        repository    = optional(string)
        chart_name    = optional(string)
        }))
      })
    monitor = object({
      enabled = bool
      helm = optional(object({
        version       = optional(string)
        release_name  = optional(string)
        repository    = optional(string)
        chart_name    = optional(string)
        }))
      })
    })
  }
