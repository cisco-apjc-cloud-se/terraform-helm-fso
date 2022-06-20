terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

### Set Defaults ###
locals {
  iwo = defaults(var.iwo, {
    release_name              = "iwo-collector"
    server_version            = "8.4"
    collector_image_version   = "8.4.4.1"
    dc_image_version          = "1.0.9-110"
  })
}

### Kubernetes  ###
resource "kubernetes_namespace" "iwo" {
  metadata {
    annotations = {
      name = local.iwo.namespace
    }
    labels = {
      "app.kubernetes.io/name" = local.iwo.namespace
    }
    name = local.iwo.namespace
  }
}

### Helm ###

## Add IWO K8S Collector Release ##
resource "helm_release" "iwo-collector" {
 namespace   = kubernetes_namespace.iwo.metadata[0].name
 name        = local.iwo.release_name
 # repository  = local.iwo.repository - chart_url used
 chart       = local.iwo.chart_url

 set {
   ## Get latest DC image
   name  = "connectorImage.tag"
   value = local.iwo.dc_image_version
 }

 set {
   name  = "iwoServerVersion"
   value = local.iwo.server_version
 }

 set {
   name  = "collectorImage.tag"
   value = local.iwo.collector_image_version
 }

 set {
   name  = "targetName"
   value = local.iwo.cluster_name
 }

}
