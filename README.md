# Kubernetes Generic Helm Chart with Common Templates

This folder contains a generic Helm chart structure for deploying 10 applications with a reusable common subchart.

## Structure

- `Chart.yaml` - root Helm chart metadata
- `values.yaml` - default common values
- `values-override.yaml` - example override values file
- `charts/common/` - reusable common subchart
- `charts/common/templates/` - shared templates for namespace, deployment, service, ingress

## How to use

From `C:\Users\aq2\k8s-multi-app`:

```powershell
helm dependency update
helm install my-release . -f values.yaml
```

To override values using a diff file:

```powershell
helm install my-release . -f values.yaml -f values-override.yaml
```

## Fully automated bootstrap

Run the automation script to create missing chart files, initialize Git, update dependencies, and deploy the release:

```powershell
.\bootstrap.ps1
```

## Customize apps

Update `values.yaml`:

- `common.apps` list for app names, image names, ports, and hosts
- `common.namespace` for the deployment namespace
- `common.replicaCount` for replica count
- `common.ingress.enabled` to enable or disable ingress
- `common.resources` for CPU/memory requests and limits

## Notes

- `charts/common` is a reusable subchart; the root chart uses it as a dependency.
- Add or remove apps in `common.apps` to manage how many applications Helm deploys.
- Use `-f values-override.yaml` to change only the values you need.
