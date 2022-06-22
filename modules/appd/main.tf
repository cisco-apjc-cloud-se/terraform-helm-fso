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
    kubernetes = {
      namespace     = "appd"
      release_name  = "appd-operator"
      repository    = "https://ciscodevnet.github.io/appdynamics-charts"
      chart_name    = "cluster-agent"
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
    }
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

## AppDynamics Kubernetes Operator < 22.5 ##
resource "helm_release" "appd_operator" {
  namespace   = kubernetes_namespace.appd.metadata[0].name
  name        = local.appd.kubernetes.release_name #"appd-operator"
  repository  = local.appd.kubernetes.repository
  chart       = local.appd.kubernetes.chart_name
  values = [ <<EOF

installClusterAgent: ${local.appd.cluster_agent.install_service}
installInfraViz: ${local.appd.machine_agent.install_service}

infraViz:
  enableContainerHostId: ${local.appd.machine_agent.infraviz.enable_container_hostid}
  enableDockerViz: ${local.appd.machine_agent.infraviz.enable_dockerviz}
  enableMasters: ${local.appd.machine_agent.infraviz.enable_masters}
  enableServerViz: ${local.appd.machine_agent.infraviz.enable_serverviz}
  nodeOS: linux
  stdoutLogging: ${local.appd.machine_agent.infraviz.stdout_logging}

netViz:
  enabled: ${local.appd.machine_agent.netviz.enabled}
  netVizPort: ${local.appd.machine_agent.netviz.port}

clusterAgent:
 appName: ${local.appd.cluster_agent.app_name}
 nsToMonitorRegex: ${local.appd.cluster_agent.monitor_namespace_regex}

instrumentationConfig:
 enabled: ${local.appd.autoinstrument.enabled}
 instrumentationMethod: env
 nsToInstrumentRegex: ${local.appd.autoinstrument.namespace_regex}
 defaultAppName: ${local.appd.autoinstrument.default_appname}
 appNameStrategy: ${local.appd.autoinstrument.appname_strategy}
 instrumentationRules:
   - language: java
     runAsUser: ${local.appd.autoinstrument.java.runasuser}
     labelMatch:
       - framework: java
     imageInfo:
       image: ${local.appd.autoinstrument.java.image}
       agentMountPath: /opt/appdynamics
       imagePullPolicy: ${local.appd.autoinstrument.java.imagepullpolicy}
   - language: dotnetcore
     runAsUser: ${local.appd.autoinstrument.dotnetcore.runasuser}
     labelMatch:
       - framework: dotnetcore
     imageInfo:
       image: ${local.appd.autoinstrument.dotnetcore.image}
       agentMountPath: /opt/appdynamics
       imagePullPolicy: ${local.appd.autoinstrument.dotnetcore.imagepullpolicy}
   - language: nodejs
     runAsUser: ${local.appd.autoinstrument.nodejs.runasuser}
     labelMatch:
       - framework: nodejs
     imageInfo:
       image: ${local.appd.autoinstrument.nodejs.image}
       agentMountPath: /opt/appdynamics
       imagePullPolicy: ${local.appd.autoinstrument.nodejs.imagepullpolicy}

imageInfo:
 imagePullPolicy: ${local.appd.kubernetes.imageinfo.imagepullpolicy}
 agentImage: ${local.appd.kubernetes.imageinfo.clusteragent.image}
 agentTag: ${local.appd.kubernetes.imageinfo.clusteragent.tag}
 operatorImage: ${local.appd.kubernetes.imageinfo.operator.image}
 operatorTag: ${local.appd.kubernetes.imageinfo.operator.tag}
 machineAgentImage: ${local.appd.kubernetes.imageinfo.machineagent.image}
 machineAgentTag: ${local.appd.kubernetes.imageinfo.machineagent.tag}
 machineAgentWinImage: ${local.appd.kubernetes.imageinfo.machineagentwin.image}
 machineAgentWinTag: ${local.appd.kubernetes.imageinfo.machineagentwin.tag}
 netVizImage: ${local.appd.kubernetes.imageinfo.netviz.image}
 netvizTag: ${local.appd.kubernetes.imageinfo.netviz.tag}

controllerInfo:
 url: ${local.appd.account.url == null ? format("https://%s.saas.appdynamics.com:443", local.appd.account.name ) : local.appd.account.url }
 account: ${local.appd.account.name}
 username: ${local.appd.account.username}
 password: ${local.appd.account.password}
 accessKey: ${local.appd.account.key}
 globalAccount: ${local.appd.account.global_account } # To be provided when using machineAgent Window Image

agentServiceAccount: appdynamics-cluster-agent
operatorServiceAccount: appdynamics-operator
infravizServiceAccount: appdynamics-infraviz

# Disabled by default - Now uses direct helm chart separately
install:
  metrics-server: false

EOF
   ]
}
