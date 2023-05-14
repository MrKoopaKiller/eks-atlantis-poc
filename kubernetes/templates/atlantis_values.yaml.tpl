## -------------------------- ##
# Atlantis Helm chart values #
## -------------------------- ##

orgAllowlist: ${org_allowlist}
logLevel: "info"

github:
  user: ${gh_user}
  token: ${gh_token}
  secret: ${gh_webhook_secret}

aws: {}
serviceAccountSecrets:
image:
  repository: ghcr.io/runatlantis/atlantis
  tag: ""
  pullPolicy: Always
allowForkPRs: false
allowDraftPRs: false
hidePrevPlanComments: false
defaultTFVersion: 1.4.6
disableApply: false
disableApplyAll: false
disableRepoLocking: false
enableDiffMarkdownFormat: false

basicAuth:
  username: "atlantis"
  password: "${atlantis_basic_auth_password}"

commonLabels: {}

livenessProbe:
  enabled: true
  periodSeconds: 60
  initialDelaySeconds: 5
  timeoutSeconds: 5
  successThreshold: 1
  failureThreshold: 5
  scheme: HTTP
readinessProbe:
  enabled: true
  periodSeconds: 60
  initialDelaySeconds: 5
  timeoutSeconds: 5
  successThreshold: 1
  failureThreshold: 5
  scheme: HTTP

service:
  type: NodePort
  port: 80
  targetPort: 4141
  loadBalancerIP: null

podTemplate:
  annotations: {}
  labels: {}

statefulSet:
  annotations: {}
  labels: {}
  securityContext:
    fsGroup: 1000
    runAsUser: 100
    fsGroupChangePolicy: "OnRootMismatch"
  priorityClassName: ""
  updateStrategy: {}
  shareProcessNamespace: false

ingress:
  enabled: true
  ingressClassName:
  apiVersion: ""
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}]'
    alb.ingress.kubernetes.io/security-groups: allow_http

  path: /*
  pathType: ImplementationSpecific
  host:

  hosts:
  tls: []
  labels: {}

resources:
  requests:
    memory: 1Gi
    cpu: 100m
  limits:
    memory: 1Gi
    cpu: 100m

volumeClaim:
  enabled: true
  dataStorage: 5Gi

replicaCount: 1

test:
  enabled: true
  image: lachlanevenson/k8s-kubectl
  imageTag: v1.4.8-bash

nodeSelector: {}
tolerations: []
affinity: {}

topologySpreadConstraints: []

serviceAccount:
  create: true
  mount: true
  name: ${atlantis_service_account_name}
  annotations:
    eks.amazonaws.com/role-arn: "${atlantis_irsa_role_arn}"

enableKubernetesBackend: false
environment:
environmentSecrets: []
environmentRaw: []
loadEnvFromSecrets: []
loadEnvFromConfigMaps: []
googleServiceAccountSecrets: []
extraVolumes: []
extraVolumeMounts: []
extraManifests: []
initContainers: []
extraArgs: []
extraContainers: []
containerSecurityContext: {}

servicemonitor:
  enabled: false
  interval: "30s"
  auth:
    basicAuth:
      enabled: false
    externalSecret:
      enabled: false
      name: atlantis-env
      keys:
        username: USERNAME
        password: ATLANTIS_WEB_PASSWORD

podMonitor:
  enabled: false
  interval: "30s"
redis: {}
lifecycle: {}
