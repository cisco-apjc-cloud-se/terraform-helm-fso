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
#
# ### Kubernetes Variables ###
# variable "namespace" {
#   type    = string
#   default = "appd"
# }
#
# ## IWO Collector Variables ##
# variable "cluster_name" {
#   type = string
# }
#
# variable "chart_url" {
#   type = string
# }
#
# variable "server_version" {
#   type = string
#   default = "8.4"
# }
#
# variable "collector_image_version" {
#   type = string
#   default = "8.4.4.1"
# }
#
# variable "dc_image_version" {
#   type = string
#   default = "1.0.9-110"
# }
