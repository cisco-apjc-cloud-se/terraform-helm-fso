### Kubernetes Variables ###
variable "namespace" {
  type    = string
  default = "appd"
}

### Helm Variables ###
variable "repository" {
  type = string
  default = "https://ciscodevnet.github.io/appdynamics-charts"
  nullable = false
}

variable "chart_name" {
  type = string
  default = "cluster-agent"
  nullable = false
}

## AppD Variables ##
variable "account_url" {
  ## Will auto-generate from account name and SaaS service if left as null
  type = string
  default = null
}

variable "account_name" {
  type = string
}

variable "otel_api_key" {
  type = string
}

variable "account_key" {
  type = string
}

variable "account_username" {
  type = string
}

variable "account_password" {
  type = string
}

variable "global_account_name" {
  type = string
  default = ""
  nullable = false
}

### General Settings ###

variable "install_metrics_server" {
  type = bool
  default = false
  nullable = false
}

variable "install_cluster_agent" {
  type = bool
  default = true
  nullable = false
}

variable "install_machine_agents" {
  type = bool
  default = false
  nullable = false
}

### InfraViz ###
variable "infraviz_enable_container_hostid" {
  type = bool
  default = true
  nullable = false
}

variable "infraviz_enable_dockerviz" {
  type = bool
  default = true
  nullable = false
}

variable "infraviz_enable_serverviz" {
  type = bool
  default = true
  nullable = false
}

variable "infraviz_enable_masters" {
  type = bool
  default = false
  nullable = false
}

variable "infraviz_stdout_logging" {
  type = bool
  default = false
  nullable = false
}

### NetViz ###
variable "netviz_enabled" {
  type = bool
  default = false
  nullable = false
}

### Cluster Agent ###
variable "clusteragent_montior_namespace_regex" {
  default = ".*"
  nullable = false
}

### Auto Instrumentation ###
variable "autoinstrumentation_enabled" {
  type = bool
  default = false
  nullable = false
}

variable "autoinstrumentation_namespace_regex" {
  type    = string
  default = ""
  nullable = false
}

variable "autoinstrumentation_default_appname" {
  type    = string
  default = ""
  nullable = false
}

variable "autoinstrumentation_appname_strategy" {
  type    = string
  default = "manual"
  nullable = false
}

# Java
variable "autoinstrumentation_java_runasuser" {
  type    = number
  default = 10001
  nullable = false
}

variable "autoinstrumentation_java_image" {
  type    = string
  default = "docker.io/appdynamics/java-agent:latest"
  nullable = false
}

variable "autoinstrumentation_java_imagepullpolicy" {
  type    = string
  default = "Always"
  nullable = false
}

# Dotnet Core
variable "autoinstrumentation_dotnetcore_runasuser" {
  type    = number
  default = 10001
  nullable = false
}

variable "autoinstrumentation_dotnetcore_image" {
  type    = string
  default = "docker.io/appdynamics/dotnet-core-agent:latest"
  nullable = false
}

variable "autoinstrumentation_dotnetcore_imagepullpolicy" {
  type    = string
  default = "Always"
  nullable = false
}

# Node.js
variable "autoinstrumentation_nodejs_runasuser" {
  type    = number
  default = 10001
  nullable = false
}

variable "autoinstrumentation_nodejs_image" {
  type    = string
  default = "docker.io/appdynamics/nodejs-agent:21.9.0-16-alpine"  ## No Latest Image Tag
  nullable = false
}

variable "autoinstrumentation_nodejs_imagepullpolicy" {
  type    = string
  default = "IfNotPresent"
  nullable = false
}

### Image Information ###
variable "imageinfo_clusteragent_image" {
  type = string
  default = "docker.io/appdynamics/cluster-agent"
  nullable = false
}

variable "imageinfo_clusteragent_tag" {
  type = string
  default = "latest"
  nullable = false
}

variable "imageinfo_operator_image" {
  type = string
  default = "docker.io/appdynamics/cluster-agent-operator"
  nullable = false
}

variable "imageinfo_operator_tag" {
  type = string
  default = "latest"
  nullable = false
}

variable "imageinfo_imagepullpolicy" {
  type    = string
  default = "Always"
  nullable = false
}

variable "imageinfo_machineagent_image" {
  type = string
  default = "docker.io/appdynamics/machine-agent"
  nullable = false
}

variable "imageinfo_machineagent_tag" {
  type = string
  default = "latest"
  nullable = false
}

variable "imageinfo_machineagentwin_image" {
  type = string
  default = "docker.io/appdynamics/machine-agent-analytics"
  nullable = false
}

variable "imageinfo_machineagentwin_tag" {
  type = string
  default = "win-latest"
  nullable = false
}

variable "imageinfo_netviz_image" {
  type = string
  default = "docker.io/appdynamics/machine-agent-netviz"
  nullable = false
}

variable "imageinfo_netviz_tag" {
  type = string
  default = "latest"
  nullable = false
}
