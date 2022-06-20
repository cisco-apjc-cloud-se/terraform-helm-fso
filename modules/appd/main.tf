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

### Set Defaults ###
locals {
  appd = defaults(var.appd,{
    use_o2_operator = false
    kubernetes = {
      namespace     = "appd"
      release_name  = "appd-operator"
      repository    = "https://ciscodevnet.github.io/appdynamics-charts"
      chart_name    = "cluster-agent"
    }
    account = {
      global_account = ""
    }
    metrics_server = {
      release_name  = "appd-metrics-server"
      repository    = "https://kubernetes-sigs.github.io/metrics-server/"
      chart_name    = "metrics-server"
    }
    machine_agent = {
      infraviz = {
        enable_container_hostid = true
        enable_dockerviz = true
        enable_serverviz = true
        enable_masters = false
        stdout_logging = false
      }
      netviz = {
        enabled = false
        port = 3892
      }
    }
    cluster_agent = {
      monitor_namespace_regex = ".*"
      autoinstrument = {
        enabled = false
        namespace_regex = ""
        default_appname = ""
        appname_strategy = "manual"
        java = {
          enabled = false
          runasuser = 10001
          image = "docker.io/appdynamics/java-agent:latest"
          imagepullpolicy = "Always"
        }
        dotnetcore = {
          enabled = false
          runasuser = 10001
          image = "docker.io/appdynamics/dotnet-core-agent:latest"
          imagepullpolicy = "Always"
        }
        nodejs = {
          enabled = false
          runasuser = 10001
          image = "docker.io/appdynamics/nodejs-agent:21.9.0-16-alpine"  ## No Latest Image Tag
          imagepullpolicy = "Always"
        }
      }
      imageinfo = {
        imagepullpolicy = "Always"
        clusteragent = {
          image = "docker.io/appdynamics/cluster-agent"
          tag = "latest"
        }
        operator = {
          image = "docker.io/appdynamics/cluster-agent-operator"
          tag = "latest"
        }
        machineagent = {
          image = "docker.io/appdynamics/machine-agent"
          tag = "latest"
        }
        machineagentwin = {
          image = "docker.io/appdynamics/machine-agent-analytics"
          tag = "win-latest"
        }
        netviz = {
          image = "docker.io/appdynamics/machine-agent-netviz"
          tag = "latest"
        }
      }
    }
  })
}

### Kubernetes  ###

resource "kubernetes_namespace" "appd" {
  metadata {
    annotations = {
      name = local.appd.kubernetes.namespace
    }
    labels = {
      "app.kubernetes.io/name" = local.appd.kubernetes.namespace
    }
    name = local.appd.kubernetes.namespace
  }
}

### Helm ###

## Add Metrics Server Release ##
# - Required for AppD Cluster Agent

resource "helm_release" "metrics_server" {
  count = local.appd.metrics_server.install_service == true ? 1 : 0

  name        = local.appd.metrics_server.release_name # "appd-metrics-server"
  namespace   = kubernetes_namespace.appd.metadata[0].name
  repository  = local.appd.metrics_server.repository # "https://kubernetes-sigs.github.io/metrics-server/"
  chart       = local.appd.metrics_server.chart_name # "metrics-server"

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
}

# ## AppDynamics Kubernetes Operator < 22.5 ##
# resource "helm_release" "appd_operator" {
#   count = local.appd.use_o2_operator == true ? 0 : 1
#
#   namespace   = kubernetes_namespace.appd.metadata[0].name
#   name        = local.appd.kubernetes.release_name #"appd-operator"
#   repository  = local.appd.kubernetes.repository
#   chart       = local.appd.kubernetes.chart_name
#   values = [ <<EOF
#
# installClusterAgent: ${local.appd.install_cluster_agent}
# installInfraViz: ${local.appd.install_machine_agents}
#
# {% if local.appd.install_machine_agents == true }
# infraViz:
#   enableContainerHostId: ${local.appd.infraviz.enable_container_hostid}
#   enableDockerViz: ${local.appd.infraviz.enable_dockerviz}
#   enableMasters: ${local.appd.infraviz.enable_masters}
#   enableServerViz: ${local.appd.infraviz.enable_serverviz}
#   nodeOS: linux
#   stdoutLogging: ${local.appd.infraviz.stdout_logging}
#
# netViz:
#   enabled: ${local.appd.netviz.enabled}
#   netVizPort: ${local.appd.netviz.port}
# {% endif }
#
# {% if local.appd.install_cluster_agent == true }
# clusterAgent:
#  appName: ${local.appd.cluster.app_name}
#  nsToMonitorRegex: ${local.appd.cluster.montior_namespace_regex}
# {% endif }
#
# instrumentationConfig:
#  enabled: ${local.appd.autoinstrument.enabled}
#  instrumentationMethod: env
#  nsToInstrumentRegex: ${local.appd.autoinstrument.namespace_regex}
#  defaultAppName: ${local.appd.autoinstrument.default_appname}
#  appNameStrategy: ${local.appd.autoinstrument.appname_strategy}
#  instrumentationRules:
#  {% if local.appd.autoinstrument.java != null }
#    - language: java
#      runAsUser: ${local.appd.autoinstrument.java.runasuser}
#      labelMatch:
#        - framework: java
#      imageInfo:
#        image: ${local.appd.autoinstrument.java.image}
#        agentMountPath: /opt/appdynamics
#        imagePullPolicy: ${local.appd.autoinstrument.java.imagepullpolicy}
#   {% endif }
#   {% if local.appd.autoinstrument.dotnetcore != null }
#    - language: dotnetcore
#      runAsUser: ${local.appd.autoinstrument.dotnetcore.runasuser}
#      labelMatch:
#        - framework: dotnetcore
#      imageInfo:
#        image: ${local.appd.autoinstrument.dotnetcore.image}
#        agentMountPath: /opt/appdynamics
#        imagePullPolicy: ${local.appd.autoinstrument.dotnetcore.imagepullpolicy}
#   {% endif }
#   {% if local.appd.autoinstrument.nodejs != null }
#    - language: nodejs
#      runAsUser: ${local.appd.autoinstrument.nodejs.runasuser}
#      labelMatch:
#        - framework: nodejs
#      imageInfo:
#        image: ${local.appd.autoinstrument.nodejs.image}
#        agentMountPath: /opt/appdynamics
#        imagePullPolicy: ${local.appd.autoinstrument.nodejs.imagepullpolicy}
#   {% endif }
#
# imageInfo:
#  agentImage: ${local.appd.imageinfo.clusteragent.image}
#  agentTag: ${local.appd.imageinfo.clusteragent.tag}
#  operatorImage: ${local.appd.imageinfo.operator.image}
#  operatorTag: ${local.appd.imageinfo.operator.tag}
#  imagePullPolicy: ${local.appd.imageinfo.imagepullpolicy}
#  {% if local.appd.install_machine_agents == true }
#  machineAgentImage: ${local.appd.imageinfo.machineagent.image}
#  machineAgentTag: ${local.appd.imageinfo.machineagent.tag}
#  machineAgentWinImage: ${local.appd.imageinfo.machineagentwin.image}
#  machineAgentWinTag: ${local.appd.imageinfo.machineagentwin.tag}
#  netVizImage: ${local.appd.imageinfo.netviz.image}
#  netvizTag: ${local.appd.imageinfo.netviz.tag}
#  {% endif }
# controllerInfo:
#  url: ${local.appd.account.url == null ? format("https://%s.saas.appdynamics.com:443", local.appd.account.name ) : local.appd.account.url }
#  account: ${local.appd.account.name}
#  username: ${local.appd.account.username}
#  password: ${local.appd.account.password}
#  accessKey: ${local.appd.account.key}
#  globalAccount: ${local.appd.account.global_account == null ? "" : local.appd.account.global_account }   # To be provided when using machineAgent Window Image
#
# agentServiceAccount: appdynamics-cluster-agent
# operatorServiceAccount: appdynamics-operator
# infravizServiceAccount: appdynamics-infraviz
#
# # Disabled by default - Now uses direct helm chart
# install:
#   metrics-server: ${local.appd.install_metrics_server}
#
# EOF
#    ]
# }
#
# ## AppDynamics Kubernetes Operator >= 22.5 ##
# resource "helm_release" "appd-operator-o2" {
#   count = local.appd.use_o2_operator == true ? 1 : 0
#
#   namespace   = kubernetes_namespace.appd.metadata[0].name
#   name        = "appd-operator-o2"
#   repository  = local.appd.kubernetes.repository
#   chart       = local.appd.kubernetes.chart_name
#   values = []
# }
