<#
.SYNOPSIS
  Full automation for the generic Helm multi-app chart.
.DESCRIPTION
  Creates missing Helm chart files, initializes Git, installs dependencies, and deploys the chart.
#>

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $Root

function Write-Info($message) {
    Write-Host "[INFO] $message" -ForegroundColor Cyan
}

function Write-ErrorAndExit($message) {
    Write-Host "[ERROR] $message" -ForegroundColor Red
    exit 1
}

function Ensure-Directory($path) {
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Path $path | Out-Null
        Write-Info "Created directory: $path"
    }
}

function Ensure-File($path, $content) {
    if (-not (Test-Path $path)) {
        $dir = Split-Path -Parent $path
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir | Out-Null
        }
        Set-Content -Path $path -Value $content -Encoding utf8
        Write-Info "Created file: $path"
    }
}

Write-Info "Bootstrapping Helm multi-app chart in '$Root'"

Ensure-Directory "charts/common/templates"

$files = @{
    "Chart.yaml" = @"
apiVersion: v2
name: k8s-multi-app
description: Generic Helm chart for deploying multiple applications using a reusable common subchart
type: application
version: 0.1.0
appVersion: "1.0"
dependencies:
  - name: common
    version: 0.1.0
    repository: file://charts/common
"@

    "values.yaml" = @"
common:
  namespace: multi-app
  appDomain: example.com
  replicaCount: 2
  ingress:
    enabled: true
    ingressClassName: nginx
  resources:
    requests:
      cpu: 100m
      memory: 128Mi
    limits:
      cpu: 500m
      memory: 256Mi
  env:
    - name: ENVIRONMENT
      value: production
  apps:
    - name: app1
      image: your-registry/app1:latest
      port: 8080
      host: app1.example.com
    - name: app2
      image: your-registry/app2:latest
      port: 8080
      host: app2.example.com
    - name: app3
      image: your-registry/app3:latest
      port: 8080
      host: app3.example.com
    - name: app4
      image: your-registry/app4:latest
      port: 8080
      host: app4.example.com
    - name: app5
      image: your-registry/app5:latest
      port: 8080
      host: app5.example.com
    - name: app6
      image: your-registry/app6:latest
      port: 8080
      host: app6.example.com
    - name: app7
      image: your-registry/app7:latest
      port: 8080
      host: app7.example.com
    - name: app8
      image: your-registry/app8:latest
      port: 8080
      host: app8.example.com
    - name: app9
      image: your-registry/app9:latest
      port: 8080
      host: app9.example.com
    - name: app10
      image: your-registry/app10:latest
      port: 8080
      host: app10.example.com
"@

    "values-override.yaml" = @"
common:
  replicaCount: 1
  ingress:
    enabled: true
  apps:
    - name: app1
      image: your-registry/app1:staging
    - name: app2
      image: your-registry/app2:staging
"@

    "charts/common/Chart.yaml" = @"
apiVersion: v2
name: common
description: Common reusable subchart for multi-app manifests
type: application
version: 0.1.0
appVersion: "1.0"
"@

    "charts/common/values.yaml" = @"
namespace: multi-app
replicaCount: 2
ingress:
  enabled: true
  ingressClassName: nginx
resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 256Mi
env:
  - name: ENVIRONMENT
    value: production
apps:
  - name: app1
    image: your-registry/app1:latest
    port: 8080
    host: app1.example.com
  - name: app2
    image: your-registry/app2:latest
    port: 8080
    host: app2.example.com
  - name: app3
    image: your-registry/app3:latest
    port: 8080
    host: app3.example.com
  - name: app4
    image: your-registry/app4:latest
    port: 8080
    host: app4.example.com
  - name: app5
    image: your-registry/app5:latest
    port: 8080
    host: app5.example.com
  - name: app6
    image: your-registry/app6:latest
    port: 8080
    host: app6.example.com
  - name: app7
    image: your-registry/app7:latest
    port: 8080
    host: app7.example.com
  - name: app8
    image: your-registry/app8:latest
    port: 8080
    host: app8.example.com
  - name: app9
    image: your-registry/app9:latest
    port: 8080
    host: app9.example.com
  - name: app10
    image: your-registry/app10:latest
    port: 8080
    host: app10.example.com
"@

    "charts/common/templates/_helpers.tpl" = @"
{{- define \"common.labels\" -}}
app.kubernetes.io/name: {{ .name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
{{- end -}}
"@

    "charts/common/templates/namespace.yaml" = @"
apiVersion: v1
kind: Namespace
metadata:
  name: {{ .Values.namespace }}
  labels:
    app.kubernetes.io/managed-by: helm
    app.kubernetes.io/name: multi-app
"@

    "charts/common/templates/deployment.yaml" = @"
{{- range .Values.apps }}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .name }}
  namespace: {{ $.Values.namespace }}
  labels:
    app: {{ .name }}
    chart: {{ $.Chart.Name }}
spec:
  replicas: {{ $.Values.replicaCount }}
  selector:
    matchLabels:
      app: {{ .name }}
  template:
    metadata:
      labels:
        app: {{ .name }}
    spec:
      containers:
        - name: {{ .name }}
          image: {{ .image }}
          ports:
            - containerPort: {{ .port | default 8080 }}
          env:
{{ toYaml $.Values.env | indent 12 }}
          resources:
            requests:
              cpu: {{ $.Values.resources.requests.cpu }}
              memory: {{ $.Values.resources.requests.memory }}
            limits:
              cpu: {{ $.Values.resources.limits.cpu }}
              memory: {{ $.Values.resources.limits.memory }}
---
{{- end }}
"@

    "charts/common/templates/service.yaml" = @"
{{- range .Values.apps }}
apiVersion: v1
kind: Service
metadata:
  name: {{ .name }}
  namespace: {{ $.Values.namespace }}
  labels:
    app: {{ .name }}
spec:
  selector:
    app: {{ .name }}
  ports:
    - protocol: TCP
      port: 80
      targetPort: {{ .port | default 8080 }}
  type: ClusterIP
---
{{- end }}
"@

    "charts/common/templates/ingress.yaml" = @"
{{- if .Values.ingress.enabled }}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: multi-app-ingress
  namespace: {{ .Values.namespace }}
  annotations:
    kubernetes.io/ingress.class: {{ .Values.ingress.ingressClassName | default \"nginx\" }}
spec:
  rules:
{{- range .Values.apps }}
    - host: {{ .host }}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: {{ .name }}
                port:
                  number: 80
{{- end }}
{{- end }}
"@
}

foreach ($path in $files.Keys) {
    Ensure-File $path $files[$path]
}

if (-not (Test-Path ".git")) {
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-ErrorAndExit "Git is not installed or not available on PATH. Install Git before continuing."
    }
    git init | Out-Null
    Write-Info "Initialized Git repository"
}

if (Get-Command git -ErrorAction SilentlyContinue) {
    $isRepo = & git rev-parse --is-inside-work-tree 2>$null
    if ($isRepo -eq 'true') {
        $status = & git status --porcelain
        if (-not $status) {
            Write-Info "Git repository is clean."
        }
        & git add . | Out-Null
        & git commit -m "Bootstrap generic Helm multi-app chart" 2>$null | Out-Null
        Write-Info "Created initial Git commit."
    }
}

if (-not (Get-Command helm -ErrorAction SilentlyContinue)) {
    Write-ErrorAndExit "Helm is not installed or not available on PATH. Install Helm to continue."
}

Write-Info "Updating Helm dependencies..."
helm dependency update | Write-Host

Write-Info "Deploying Helm release 'multi-app'..."
helm upgrade --install multi-app . -f values.yaml -f values-override.yaml | Write-Host

Write-Info "Deployment complete."
Write-Host "Run 'kubectl get all -n multi-app' to verify resources." -ForegroundColor Green
