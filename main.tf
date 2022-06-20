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

# locals {
#   iwo = defaults( var.iwo, {
#
#     })
#   appd = defaults( var.appd, {
#
#     })
# }

module "iwo" {
  source = "./modules/iwo"
  count = var.iwo.enabled == true ? 1 : 0

  iwo = var.iwo
  # ### Kubernetes Settings ###
  # namespace                 = var.iwo.namespace
  #
  # ### IWO Helm Chart Setttings ###
  # chart_url                 = var.iwo.chart_url
  # cluster_name              = var.iwo.cluster_name
  # server_version            = var.iwo.server_version  # Optional
  # collector_image_version   = var.iwo.collector_image_version # Optional
  # dc_image_version          = var.iwo.dc_image_version # Optional

}

module "appd" {
  source = "./modules/appd"
  count = var.appd.enabled == true ? 1 : 0

  appd = var.appd
  # ### Kubernetes Settings ###
  # namespace   = var.appd.kubernetes.namespace
  # repository  = var.appd.kubernetes.repository
  # chart_name  = var.appd.kubernetes.chart_name
  #
  # ### AppD Account Settings ###
  # account_url         = var.appd.account.url
  # account_name        = var.appd.account.name
  # otel_api_key        = var.appd.account.otel_api_key
  # account_key         = var.appd.account.key
  # account_username    = var.appd.account.username
  # account_password    = var.appd.account.password
  # global_account_name = var.appd.account.global_account
  #
  # ### General Settings ###
  # install_cluster_agent   = var.appd.install_metrics_server
  # install_machine_agents  = var.appd.install_machine_agents
  # install_metrics_server  = var.appd.install_metrics_server  ## NOTE: Separate Helm Release used, not part of AppD
  #
  # ### InfraViz ###
  # infraviz_enable_container_hostid  = try(var.appd.infraviz.enable_container_hostid, null)
  # infraviz_enable_dockerviz         = try(var.appd.infraviz.enable_dockerviz, null)
  # infraviz_enable_serverviz         = try(var.appd.infraviz.enable_serverviz, null)
  # infraviz_enable_masters           = try(var.appd.infraviz.enable_masters, null)
  # infraviz_stdout_logging           = try(var.appd.infraviz.stdout_logging, null)
  #
  # ### NetViz ###
  # netviz_enabled = try(var.appd.netviz.enabled, null) #var.netiz != null ? var.netviz.enabled : null
  #
  # ### Cluster Agent ###
  # clusteragent_app_name                  = try(var.appd.cluster.app_name, null)
  # clusteragent_montior_namespace_regex  = var.appd.cluster.montior_namespace_regex #var.cluster != null ? var.cluster.montior_namespace_regex : null
  #
  # ### Auto Instrumentation ###
  # autoinstrumentation_enabled                     = var.appd.autoinstrument.enabled # var.autoinstrument != null ? var.autoinstrument.enabled : false
  # autoinstrumentation_namespace_regex             = var.appd.autoinstrument.namespace_regex # var.autoinstrument.namespace_regex != null ? var.autoinstrument.namespace_regex : null
  # autoinstrumentation_default_appname             = var.appd.autoinstrument.default_appname #var.autoinstrument.default_appname != null ? var.autoinstrument.default_appname : null
  # autoinstrumentation_appname_strategy            = var.appd.autoinstrument.appname_strategy #var.autoinstrument.appname_strategy != null ? var.autoinstrument.appname_strategy : null
  # autoinstrumentation_java_runasuser              = try(var.appd.autoinstrument.java.runasuser, null)#var.autoinstrument.java.runasuser != null ? var.autoinstrument.java.runasuser : null
  # autoinstrumentation_java_image                  = try(var.appd.autoinstrument.java.image, null)#var.autoinstrument.java.image != null ? var.autoinstrument.java.image : null
  # autoinstrumentation_java_imagepullpolicy        = try(var.appd.autoinstrument.java.imagepullpolicy, null)#var.autoinstrument.java.imagepullpolicy != null ? var.autoinstrument.java.imagepullpolicy : null
  # autoinstrumentation_dotnetcore_runasuser        = try(var.appd.autoinstrument.dotnetcore.runasuser, null)#var.autoinstrument.dotnetcore.runasuser != null ? var.autoinstrument.dotnetcore.runasuser : null
  # autoinstrumentation_dotnetcore_image            = try(var.appd.autoinstrument.dotnetcore.image, null)#var.autoinstrument.dotnetcore.image != null ? var.autoinstrument.dotnetcore.image : null
  # autoinstrumentation_dotnetcore_imagepullpolicy  = try(var.appd.autoinstrument.dotnetcore.imagepullpolicy, null)#var.autoinstrument.dotnetcore.imagepullpolicy != null ? var.autoinstrument.dotnetcore.imagepullpolicy : null
  # autoinstrumentation_nodejs_runasuser            = try(var.appd.autoinstrument.nodejs.runasuser, null)#var.autoinstrument.nodejs.runasuser != null ? var.autoinstrument.nodejs.runasuser : null
  # autoinstrumentation_nodejs_image                = try(var.appd.autoinstrument.nodejs.image, null)#var.autoinstrument.nodejs.image != null ? var.autoinstrument.nodejs.image : null  # Note: No Latest Image Tag
  # autoinstrumentation_nodejs_imagepullpolicy      = try(var.appd.autoinstrument.nodejs.runasuser,null)#var.autoinstrument.nodejs.runasuser != null ? var.autoinstrument.nodejs.runasuser : null
  #
  # ### Image Information ###
  # imageinfo_clusteragent_image    = try(var.appd.imageinfo.clusteragent.image, null)#var.imageinfo.clusteragent.image != null ? var.imageinfo.clusteragent.image : null
  # imageinfo_clusteragent_tag      = try(var.appd.imageinfo.clusteragent.tag, null)#var.imageinfo.clusteragent.tag != null ? var.imageinfo.clusteragent.tag : null
  # imageinfo_operator_image        = try(var.appd.imageinfo.operator.image, null)#var.imageinfo.operator.image != null ? var.imageinfo.operator.image : null
  # imageinfo_operator_tag          = try(var.appd.imageinfo.operator.tag, null)#var.imageinfo.operator.tag != null ? var.imageinfo.operator.tag : null
  # imageinfo_imagepullpolicy       = try(var.appd.imageinfo.imagepullpolicy, null)#var.imageinfo.imagepullpolicy != null ? var.imageinfo.imagepullpolicy : null
  # imageinfo_machineagent_image    = try(var.appd.imageinfo.machineagent.image, null)#var.imageinfo.machineagent.image != null ? var.imageinfo.machineagent.image : null
  # imageinfo_machineagent_tag      = try(var.appd.imageinfo.machineagent.tag, null)#var.imageinfo.machineagent.tag != null ?  var.imageinfo.machineagent.tag : null
  # imageinfo_machineagentwin_image = try(var.appd.imageinfo.machineagentwin.image, null)#var.imageinfo.machineagentwin.image != null ? var.imageinfo.machineagentwin.image : null
  # imageinfo_machineagentwin_tag   = try(var.appd.imageinfo.machineagentwin.tag, null)#var.imageinfo.machineagentwin.tag != null ? var.imageinfo.machineagentwin.tag : null
  # imageinfo_netviz_image          = try(var.appd.imageinfo.netviz.image, null)#var.imageinfo.netviz.image != null ? var.imageinfo.netviz.image : null
  # imageinfo_netviz_tag            = try(var.appd.imageinfo.netviz.tag, null)#var.imageinfo.netviz.tag != null ? var.imageinfo.netviz.tag : null
}

output "test" {
  value = module.appd[0].test
}
