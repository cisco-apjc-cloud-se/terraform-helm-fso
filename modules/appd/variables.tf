### Kubernetes Variables ###
variable "namespace" {
  type    = string
  default = "appd"
}

### Helm Variables ###
variable "repository" {
  type = string
  default = "https://ciscodevnet.github.io/appdynamics-charts"
}

variable "chart_name" {
  type = string
  default = "cluster-agent"
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
}

### General Settings ###

variable "install_metrics_server" {
  type = bool
  default = false
}

variable "install_cluster_agent" {
  type = bool
  default = true
}

variable "install_machine_agents" {
  type = bool
  default = false
}

### InfraViz ###
variable "infraviz_enable_container_hostid" {
  type = bool
  default = true
}

variable "infraviz_enable_dockerviz" {
  type = bool
  default = true
}

variable "infraviz_enable_serverviz" {
  type = bool
  default = true
}

variable "infraviz_enable_masters" {
  type = bool
  default = false
}

variable "infraviz_stdout_logging" {
  type = bool
  default = false
}

### NetViz ###
variable "netviz_enabled" {
  type = bool
  default = false
}

### Cluster Agent ###
variable "clusteragent_montior_namespace_regex" {
  default = ".*"
}

### Auto Instrumentation ###
variable "autoinstrumentation_enabled" {
  type = bool
  default = false
}

variable "autoinstrumentation_namespace_regex" {
  type    = string
  default = ""
}

variable "autoinstrumentation_default_appname" {
  type    = string
  default = ""
}

variable "autoinstrumentation_appname_strategy" {
  type    = string
  default = "manual"
}

# Java
variable "autoinstrumentation_java_runasuser" {
  type    = number
  default = 10001
}

variable "autoinstrumentation_java_image" {
  type    = string
  default = "docker.io/appdynamics/java-agent:latest"
}

variable "autoinstrumentation_java_imagepullpolicy" {
  type    = string
  default = "Always"
}

# Dotnet Core
variable "autoinstrumentation_dotnetcore_runasuser" {
  type    = number
  default = 10001
}

variable "autoinstrumentation_dotnetcore_image" {
  type    = string
  default = "docker.io/appdynamics/dotnet-core-agent:latest"
}

variable "autoinstrumentation_dotnetcore_imagepullpolicy" {
  type    = string
  default = "Always"
}

# Node.js
variable "autoinstrumentation_nodejs_runasuser" {
  type    = number
  default = 10001
}

variable "autoinstrumentation_nodejs_image" {
  type    = string
  default = "docker.io/appdynamics/nodejs-agent:21.9.0-16-alpine"  ## No Latest Image Tag
}

variable "autoinstrumentation_nodejs_imagepullpolicy" {
  type    = string
  default = "IfNotPresent"
}

### Image Information ###
variable "imageinfo_clusteragent_image" {
  type = string
  default = "docker.io/appdynamics/cluster-agent"
}

variable "imageinfo_clusteragent_tag" {
  type = string
  default = "latest"
}

variable "imageinfo_operator_image" {
  type = string
  default = "docker.io/appdynamics/cluster-agent-operator"
}

variable "imageinfo_operator_tag" {
  type = string
  default = "latest"
}

variable "imageinfo_imagepullpolicy" {
  type    = string
  default = "Always"
}

variable "imageinfo_machineagent_image" {
  type = string
  default = "docker.io/appdynamics/machine-agent"
}

variable "imageinfo_machineagent_tag" {
  type = string
  default = "latest"
}

variable "imageinfo_machineagentwin_image" {
  type = string
  default = "docker.io/appdynamics/machine-agent-analytics"
}

variable "imageinfo_machineagentwin_tag" {
  type = string
  default = "win-latest"
}

variable "imageinfo_netviz_image" {
  type = string
  default = "docker.io/appdynamics/machine-agent-netviz"
}

variable "imageinfo_netviz_tag" {
  type = string
  default = "latest"
}
