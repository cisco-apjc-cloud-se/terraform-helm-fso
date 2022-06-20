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
    # kubernetes = {
    #   namespace = "appd"
    # }
    operator = {
      enabled = true
      helm = {
        version       = "22.5.0"
        release_name  = "k8s"
        repository    = "https://ciscodevnet.github.io/appdynamics-charts"
        chart_name    = "o2-operator"
      }
    }
    monitor = {
      enabled = true
      helm = {
        version       = "22.5.0"
        release_name  = "k8s"
        repository    = "https://ciscodevnet.github.io/appdynamics-charts"
        chart_name    = "o2-k8s-monitoring"
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

# ## Add Metrics Server Release ##
# # - Required for AppD Cluster Agent
#
# resource "helm_release" "metrics_server" {
#   count = local.appd.metrics_server.install_service == true ? 1 : 0
#
#   name        = local.appd.metrics_server.release_name # "appd-metrics-server"
#   namespace   = kubernetes_namespace.appd.metadata[0].name
#   repository  = local.appd.metrics_server.repository # "https://kubernetes-sigs.github.io/metrics-server/"
#   chart       = local.appd.metrics_server.chart_name # "metrics-server"
#
#   values = [<<EOF
#     apiService:
#       create: true
#
#     defaultArgs:
#       - --cert-dir=/tmp
#       - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
#       - --kubelet-use-node-status-port
#       - --metric-resolution=15s
#       - --kubelet-insecure-tls
#
# EOF
#   ]
# }

## AppDynamics Kubernetes Operator >= 22.5 ##
resource "helm_release" "appd_k8s_operator" {
  namespace   = kubernetes_namespace.appd.metadata[0].name
  name        = local.appd.operator.helm.release_name
  repository  = local.appd.operator.helm.repository
  chart       = local.appd.operator.helm.chart_name
  values = [<<EOF
operatorServiceAccount: appdynamics-operator
operatorPod:
  image: public.ecr.aws/appdynamics-container-registry/appdynamics-operator:${local.appd.operator.helm.version}
  imagePullPolicy: Always
  resources:
    limits:
      cpu: 200m
      memory: 128Mi
    requests:
      cpu: 100m
      memory: 64Mi
  labels: {}
  annotations: {}
  nodeSelector: {}
  imagePullSecrets: []
  affinity: {}
  tolerations: []
  securityContext: {}
EOF
  ]
}


## AppDynamics Kubernetes Operator >= 22.5 ##
resource "helm_release" "appd_k8s_monitoring" {
  namespace   = kubernetes_namespace.appd.metadata[0].name
  name        = local.appd.kubernetes.release_name
  repository  = local.appd.kubernetes.repository
  chart       = local.appd.kubernetes.chart_name
  values = [<<EOF
install:
  clustermon: true
  defaultInfraCollectors: true
  logCollector: false

mTLS:
  enabled: true
  client:
    secretName: ""
    secretKeys:
      caCert: ca.crt
      tlsCert: tls.crt
      tlsKey: tls.key
  server:
    secretName: ""
    secretKeys:
      caCert: ca.crt
      tlsCert: tls.crt
      tlsKey: tls.key

# RBAC config
clustermonServiceAccount: appdynamics-clustermon
inframonServiceAccount: appdynamics-inframon
otelCollectorServiceAccount: appdynamics-otel-collector
logCollectorServiceAccount: appdynamics-log-collector

# Clustermon Configs
clustermonConfig:
  clusterName: null
  logLevel: info
  logFilesMaxSizeMb: 10
  logFilesNumBackups: 4
  printToStdout: "true"

  filters:
    namespace:
      includeRegex: ".*"
      excludeRegex: ""
    entity:
      excludeRegex: ""
      excludeLabels: []
    label:
      excludeRegex: ""

  ingressControllers: {}

  events:
    enabled: true
    severityToExclude: [Normal]
    reasonToExclude: []
    severeGroupByReason: []

# Infra Manager Configs
infraManagerConfig:
  logLevel: info
  logFilesMaxSizeMb: 10
  logFilesNumBackups: 4
  printToStdout: "true"

# Servermon Configs
servermonConfig:
  logLevel: info
  logFilesMaxSizeMb: 10
  logFilesNumBackups: 4

# Containermon Configs
containermonConfig:
  logLevel: info
  logFilesMaxSizeMb: 10
  logFilesNumBackups: 4

# LogCollector Configs
logCollectorConfig:
  container:
    conditions:
      - condition: {}
        multiLinePattern:
        multiLineNegate:
        multiLineMatch:
        messageParserLog4JPattern:
        messageParserLogbackPattern:
        enableJSONLogs:
        jsonTimestampField:
        jsonTimestampPattern:
        messageParserTimestampFormat:
        messageParserGrokPatterns:
        grokTimestampField:
        grokTimestampPattern:
        enableInfraLogs:
    clusterName:
    batchSize:
    loggingLevel:
    loggingSelectors: []
    monitoringEnabled:
    monitoringLoggingPeriod:
  filebeatYaml: ""

# Deployment specific configs
clustermonPod:
  image: public.ecr.aws/appdynamics-container-registry/appdynamics-cloud-k8s-monitoring:22.5.0
  imagePullPolicy: Always
  resources:
    limits:
      cpu: 1000m
      memory: 1000Mi
    requests:
      cpu: 500m
      memory: 750Mi
  labels: {}
  annotations: {}
  nodeSelector: {}
  imagePullSecrets: []
  affinity: {}
  tolerations: []
  securityContext: {}

# Daemonset specific configs
inframonPod:
  image: public.ecr.aws/appdynamics-container-registry/appdynamics-cloud-k8s-monitoring:22.5.0
  imagePullPolicy: Always
  resources:
    limits:
      cpu: 350m
      memory: 100Mi
    requests:
      cpu: 200m
      memory: 64Mi
  labels: {}
  annotations: {}
  nodeSelector: {}
  imagePullSecrets: []
  affinity: {}
  tolerations: []
  securityContext: {}

# Daemonset specific configs
otelCollectorPod:
  image: public.ecr.aws/appdynamics-container-registry/appdynamics-otel-collector:22.1.0
  imagePullPolicy: Always
  env: []
  resources:
    limits:
      cpu: 400m
      memory: 300Mi
    requests:
      cpu: 200m
      memory: 150Mi
  labels: {}
  annotations: {}
  nodeSelector: {}
  imagePullSecrets: []
  affinity: {}
  tolerations: []
  securityContext: {}

# Daemonset specific configs
logCollectorPod:
  image: public.ecr.aws/appdynamics-container-registry/appdynamics-beats:22.4.0
  imagePullPolicy: Always
  resources:
    limits:
      cpu: 400m
      memory: 300Mi
    requests:
      cpu: 200m
      memory: 150Mi
  labels: {}
  annotations: {}
  nodeSelector: {}
  imagePullSecrets: []
  affinity: {}
  tolerations: []
  securityContext: {}

otelCollector:
  config:
    oauth2client:
      clientId: ""
      clientSecret: ""
      tenantId: ""
    endpoint: ""
    logLevel: "info"
  configOverride: ""
EOF
  ]
}
