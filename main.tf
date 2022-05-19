terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
  experiments = [module_variable_optional_attrs]
}

# ### Decode Kube Config ###
# # Assumes kube_config is passed as b64 encoded
# locals {
#   kube_config = yamldecode(base64decode(var.kube_config)) #yamldecode(base64decode(data.terraform_remote_state.iks.outputs.kube_config))
# }
#
# ### Providers ###
# provider "kubernetes" {
#   # alias = "iks-k8s"
#   host                   = local.kube_config.clusters[0].cluster.server
#   cluster_ca_certificate = base64decode(local.kube_config.clusters[0].cluster.certificate-authority-data)
#   client_certificate     = base64decode(local.kube_config.users[0].user.client-certificate-data)
#   client_key             = base64decode(local.kube_config.users[0].user.client-key-data)
# }
#
# provider "helm" {
#   kubernetes {
#     host                   = local.kube_config.clusters[0].cluster.server
#     cluster_ca_certificate = base64decode(local.kube_config.clusters[0].cluster.certificate-authority-data)
#     client_certificate     = base64decode(local.kube_config.users[0].user.client-certificate-data)
#     client_key             = base64decode(local.kube_config.users[0].user.client-key-data)
#   }
# }

module "iwo" {
  source = "./modules/iwo"
  count = var.iwo.enabled == true ? 1 : 0

  ### Kubernetes Settings ###
  namespace                 = var.iwo.namespace

  ### IWO Helm Chart Setttings ###
  chart_url                 = var.iwo.chart_url
  cluster_name              = var.iwo.cluster_name
  server_version            = var.iwo.server_version  # Optional
  collector_image_version   = var.iwo.collector_image_version # Optional
  dc_image_version          = var.iwo.dc_image_version # Optional

}

module "appd" {
  source = "./modules/appd"
  count = var.appd.enabled == true ? 1 : 0

  ### Kubernetes Settings ###
  namespace   = var.appd.kubernetes.namespace
  repository  = var.appd.kubernetes.repository
  chart_name  = var.appd.kubernetes.chart_name

  ### AppD Account Settings ###
  account_url         = var.appd.account.url
  account_name        = var.appd.account.name
  otel_api_key        = var.appd.account.otel_api_key
  account_key         = var.appd.account.key
  account_username    = var.appd.account.username
  account_password    = var.appd.account.password
  global_account_name = var.appd.account.global_account

  ### General Settings ###
  install_cluster_agent   = var.appd.install_metrics_server
  install_machine_agents  = var.appd.install_machine_agents
  install_metrics_server  = var.appd.install_metrics_server

  ### InfraViz ###
  infraviz_enable_container_hostid  = var.infraviz.enable_container_hostid
  infraviz_enable_dockerviz         = var.infraviz.enable_dockerviz
  infraviz_enable_serverviz         = var.infraviz.enable_serverviz
  infraviz_enable_masters           = var.infraviz.enable_masters
  infraviz_stdout_logging           = var.infraviz.stdout_logging

  ### NetViz ###
  netviz_enabled = var.netviz.enabled

  ### Cluster Agent ###
  clusteragent_montior_namespace_regex = var.cluster.montior_namespace_regex

  ### Auto Instrumentation ###
  autoinstrumentation_enabled                     = var.autoinstrument.enabled
  autoinstrumentation_namespace_regex             = var.autoinstrument.namespace_regex
  autoinstrumentation_default_appname             = var.autoinstrument.default_appname
  autoinstrumentation_appname_strategy            = var.autoinstrument.appname_strategy
  autoinstrumentation_java_runasuser              = var.autoinstrument.java.runasuser
  autoinstrumentation_java_image                  = var.autoinstrument.java.image
  autoinstrumentation_java_imagepullpolicy        = var.autoinstrument.java.imagepullpolicy
  autoinstrumentation_dotnetcore_runasuser        = var.autoinstrument.dotnetcore.runasuser
  autoinstrumentation_dotnetcore_image            = var.autoinstrument.dotnetcore.image
  autoinstrumentation_dotnetcore_imagepullpolicy  = var.autoinstrument.dotnetcore.imagepullpolicy
  autoinstrumentation_nodejs_runasuser            = var.autoinstrument.nodejs.runasuser
  autoinstrumentation_nodejs_image                = var.autoinstrument.nodejs.image  # Note: No Latest Image Tag
  autoinstrumentation_nodejs_imagepullpolicy      = var.autoinstrument.nodejs.runasuser

  ### Image Information ###
  imageinfo_clusteragent_image    = var.imageinfo.clusteragent.image
  imageinfo_clusteragent_tag      = var.imageinfo.clusteragent.tag
  imageinfo_operator_image        = var.imageinfo.operator.image
  imageinfo_operator_tag          = var.imageinfo.operator.tag
  imageinfo_imagepullpolicy       = var.imageinfo.imagepullpolicy
  imageinfo_machineagent_image    = var.imageinfo.machineagent.image
  imageinfo_machineagent_tag      = var.imageinfo.machineagent.tag
  imageinfo_machineagentwin_image = var.imageinfo.machineagentwin.image
  imageinfo_machineagentwin_tag   = var.imageinfo.machineagentwin.tag
  imageinfo_netviz_image          = var.imageinfo.netviz.image
  imageinfo_netviz_tag            = var.imageinfo.netviz.tag
}
