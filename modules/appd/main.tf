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

resource "kubernetes_namespace" "appd" {
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

## Add Metrics Server Release ##
# - Required for AppD Cluster Agent

resource "helm_release" "metrics-server" {
  count = var.install_metrics_server == true ? 1 : 0

  name = "appd-metrics-server"
  namespace   = kubernetes_namespace.appd.metadata[0].name
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  # repository = "https://charts.bitnami.com/bitnami"
  chart = "metrics-server"

  values = [<<EOF
    apiService:
      create: true

    defaultArgs:
      - --cert-dir=/tmp
      - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
      - --kubelet-use-node-status-port
      - --metric-resolution=15s
      - --kubelet-insecure-tls

EOF
  ]

  # set {
  #   name = "apiService.create"
  #   value = true
  # }
  #
  # set {
  #   name = "extraArgs.kubelet-insecure-tls"
  #   value = true
  # }
  #
  # set {
  #   name = "extraArgs.kubelet-preferred-address-types"
  #   value = "InternalIP\\,ExternalIP\\,Hostname"
  # }

}

## AppDynamics Kubernetes Operator ##
resource "helm_release" "appd-operator" {
   namespace   = kubernetes_namespace.appd.metadata[0].name
   name        = "appd-operator"

   repository  = var.repository
   chart       = var.chart_name

   values = [ <<EOF

installClusterAgent: ${var.install_cluster_agent}
installInfraViz: ${var.install_machine_agents}

infraViz:
  enableContainerHostId: ${var.infraviz_enable_container_hostid}
  enableDockerViz: ${var.infraviz_enable_dockerviz}
  enableMasters: ${var.infraviz_enable_masters}
  enableServerViz: ${var.infraviz_enable_serverviz}
  nodeOS: linux
  stdoutLogging: ${var.infraviz_stdout_logging}

netViz:
  enabled: ${var.netviz_enabled}
  # netVizPort: 3892

clusterAgent:
 nsToMonitorRegex: ${var.clusteragent_montior_namespace_regex}

instrumentationConfig:
 enabled: ${var.autoinstrumentation_enabled}
 instrumentationMethod: env
 nsToInstrumentRegex: ${var.autoinstrumentation_namespace_regex}
 defaultAppName: ${var.autoinstrumentation_default_appname}
 appNameStrategy: ${var.autoinstrumentation_appname_strategy}
 instrumentationRules:
   - language: java
     # runAsGroup: 10001
     runAsUser: ${var.autoinstrumentation_java_runasuser}
     labelMatch:
       - framework: java
     imageInfo:
       image: ${var.autoinstrumentation_java_image}
       agentMountPath: /opt/appdynamics
       imagePullPolicy: ${var.autoinstrumentation_java_imagepullpolicy}
   - language: dotnetcore
     runAsUser: ${var.autoinstrumentation_dotnetcore_runasuser}
     labelMatch:
       - framework: dotnetcore
     imageInfo:
       image: ${var.autoinstrumentation_dotnetcore_image}
       agentMountPath: /opt/appdynamics
       imagePullPolicy: ${var.autoinstrumentation_dotnetcore_imagepullpolicy}
   - language: nodejs
     runAsUser: ${var.autoinstrumentation_nodejs_runasuser}
     labelMatch:
       - framework: nodejs
     imageInfo:
       image: ${var.autoinstrumentation_nodejs_image}
       agentMountPath: /opt/appdynamics
       imagePullPolicy: ${var.autoinstrumentation_nodejs_imagepullpolicy}

imageInfo:
 agentImage: ${var.imageinfo_clusteragent_image}
 agentTag: ${var.imageinfo_clusteragent_tag}
 operatorImage: ${var.imageinfo_operator_image}
 operatorTag: ${var.imageinfo_operator_tag}
 imagePullPolicy: ${var.imageinfo_imagepullpolicy}
 machineAgentImage: ${var.imageinfo_machineagent_image}
 machineAgentTag: ${var.imageinfo_machineagent_tag}
 machineAgentWinImage: ${var.imageinfo_machineagentwin_image}
 machineAgentWinTag: ${var.imageinfo_machineagentwin_tag}
 netVizImage: ${var.imageinfo_netviz_image}
 netvizTag: ${var.imageinfo_netviz_tag}
controllerInfo:
 url: ${var.account_url == null ? format("https://%s.saas.appdynamics.com:443", var.account_name) : var.account_url}
 account: ${var.account_name}
 username: ${var.account_username}
 password: ${var.account_password}
 accessKey: ${var.account_key}
 globalAccount: ${var.global_account_name == null ? "" : var.global_account_name }   # To be provided when using machineAgent Window Image

agentServiceAccount: appdynamics-cluster-agent
operatorServiceAccount: appdynamics-operator
infravizServiceAccount: appdynamics-infraviz

# Disabled - Now uses direct helm chart
# install:
#   metrics-server:  ${var.install_metrics_server}

EOF
   ]
}
