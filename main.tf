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
  infraviz_enable_container_hostid  = var.appd.infraviz.enable_container_hostid
  infraviz_enable_dockerviz         = var.appd.infraviz.enable_dockerviz
  infraviz_enable_serverviz         = var.appd.infraviz.enable_serverviz
  infraviz_enable_masters           = var.appd.infraviz.enable_masters
  infraviz_stdout_logging           = var.appd.infraviz.stdout_logging # test

  ### NetViz ###
  netviz_enabled = var.appd.netviz.enabled #var.netiz != null ? var.netviz.enabled : null

  ### Cluster Agent ###
  clusteragent_montior_namespace_regex = var.appd.cluster.montior_namespace_regex #var.cluster != null ? var.cluster.montior_namespace_regex : null

  ### Auto Instrumentation ###
  autoinstrumentation_enabled                     = var.appd.autoinstrument.enabled # var.autoinstrument != null ? var.autoinstrument.enabled : false
  autoinstrumentation_namespace_regex             = var.appd.autoinstrument.namespace_regex # var.autoinstrument.namespace_regex != null ? var.autoinstrument.namespace_regex : null
  autoinstrumentation_default_appname             = var.appd.autoinstrument.default_appname #var.autoinstrument.default_appname != null ? var.autoinstrument.default_appname : null
  autoinstrumentation_appname_strategy            = var.appd.autoinstrument.appname_strategy #var.autoinstrument.appname_strategy != null ? var.autoinstrument.appname_strategy : null
  autoinstrumentation_java_runasuser              = var.appd.autoinstrument.java.runasuser #var.autoinstrument.java.runasuser != null ? var.autoinstrument.java.runasuser : null
  autoinstrumentation_java_image                  = var.appd.autoinstrument.java.image #var.autoinstrument.java.image != null ? var.autoinstrument.java.image : null
  autoinstrumentation_java_imagepullpolicy        = var.appd.autoinstrument.java.imagepullpolicy #var.autoinstrument.java.imagepullpolicy != null ? var.autoinstrument.java.imagepullpolicy : null
  autoinstrumentation_dotnetcore_runasuser        = var.appd.autoinstrument.dotnetcore.runasuser #var.autoinstrument.dotnetcore.runasuser != null ? var.autoinstrument.dotnetcore.runasuser : null
  autoinstrumentation_dotnetcore_image            = var.appd.autoinstrument.dotnetcore.image #var.autoinstrument.dotnetcore.image != null ? var.autoinstrument.dotnetcore.image : null
  autoinstrumentation_dotnetcore_imagepullpolicy  = var.appd.autoinstrument.dotnetcore.imagepullpolicy #var.autoinstrument.dotnetcore.imagepullpolicy != null ? var.autoinstrument.dotnetcore.imagepullpolicy : null
  autoinstrumentation_nodejs_runasuser            = var.appd.autoinstrument.nodejs.runasuser #var.autoinstrument.nodejs.runasuser != null ? var.autoinstrument.nodejs.runasuser : null
  autoinstrumentation_nodejs_image                = var.appd.autoinstrument.nodejs.image #var.autoinstrument.nodejs.image != null ? var.autoinstrument.nodejs.image : null  # Note: No Latest Image Tag
  autoinstrumentation_nodejs_imagepullpolicy      = var.appd.autoinstrument.nodejs.runasuser #var.autoinstrument.nodejs.runasuser != null ? var.autoinstrument.nodejs.runasuser : null

  ### Image Information ###
  imageinfo_clusteragent_image    = var.appd.imageinfo.clusteragent.image #var.imageinfo.clusteragent.image != null ? var.imageinfo.clusteragent.image : null
  imageinfo_clusteragent_tag      = var.appd.imageinfo.clusteragent.tag #var.imageinfo.clusteragent.tag != null ? var.imageinfo.clusteragent.tag : null
  imageinfo_operator_image        = var.appd.imageinfo.operator.image #var.imageinfo.operator.image != null ? var.imageinfo.operator.image : null
  imageinfo_operator_tag          = var.appd.imageinfo.operator.tag #var.imageinfo.operator.tag != null ? var.imageinfo.operator.tag : null
  imageinfo_imagepullpolicy       = var.appd.imageinfo.imagepullpolicy #var.imageinfo.imagepullpolicy != null ? var.imageinfo.imagepullpolicy : null
  imageinfo_machineagent_image    = var.appd.imageinfo.machineagent.image #var.imageinfo.machineagent.image != null ? var.imageinfo.machineagent.image : null
  imageinfo_machineagent_tag      = var.appd.imageinfo.machineagent.tag #var.imageinfo.machineagent.tag != null ?  var.imageinfo.machineagent.tag : null
  imageinfo_machineagentwin_image = var.appd.imageinfo.machineagentwin.image #var.imageinfo.machineagentwin.image != null ? var.imageinfo.machineagentwin.image : null
  imageinfo_machineagentwin_tag   = var.appd.imageinfo.machineagentwin.tag #var.imageinfo.machineagentwin.tag != null ? var.imageinfo.machineagentwin.tag : null
  imageinfo_netviz_image          = var.appd.imageinfo.netviz.image #var.imageinfo.netviz.image != null ? var.imageinfo.netviz.image : null
  imageinfo_netviz_tag            = var.appd.imageinfo.netviz.tag #var.imageinfo.netviz.tag != null ? var.imageinfo.netviz.tag : null
}
