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
}

# module "appd_o2" {
#   source = "./modules/appd_o2"
#   count = var.appd.enabled == true && var.appd.o2_operator.enabled == true ? 1 : 0
#
#   appd = var.appd.o2_operator
# }
