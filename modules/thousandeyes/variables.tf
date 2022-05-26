# variable "agent_list" {
#   type  = list(string)
# }

variable "http_tests2" {
  type = map(object({
    name                    = string
    interval                = number
    url                     = string
    content_regex           = string
    network_measurements    = bool # 1
    mtu_measurements        = bool # 1
    bandwidth_measurements  = bool # 0
    bgp_measurements        = bool # 1
    use_public_bgp          = bool # 1
    num_path_traces         = number # 0
    agents                  = list(string)
  }))
}

variable "agent_list" {
  type  = list(string)
}

variable "http_tests" {
  type = map(object({
    name = string
    url = string
  }))
}
