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

### Kubernetes  ###

resource "kubernetes_namespace" "iwo" {
  metadata {
    annotations = {
      name = var.namespace
    }
    labels = {
      "app.kubernetes.io/name" = var.namespace
    }
    name = var.namespace
  }
}

### Helm ###

## Add IWO K8S Collector Release ##
resource "helm_release" "iwo-collector" {
 namespace   = kubernetes_namespace.iwo-collector.metadata[0].name
 name        = "iwo-collector"

 chart       = var.chart_url

 set {
   ## Get latest DC image
   name   = "connectorImage.tag"
   value  = var.dc_image_version
 }

 set {
   name  = "iwoServerVersion"
   value = var.server_version
 }

 set {
   name  = "collectorImage.tag"
   value = var.collector_image_version
 }

 set {
   name  = "targetName"
   value = var.cluster_name
 }

}
