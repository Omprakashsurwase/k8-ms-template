# Single App Example

A complete example showing how to build, containerize, and deploy a single Node.js application using Docker, Helm, and Kubernetes.

## Structure

- `app/` - Node.js Express application
  - `index.js` - Main application file
  - `package.json` - Dependencies
- `helm/` - Helm chart for deployment
  - `Chart.yaml` - Chart metadata
  - `values.yaml` - Default configuration values
  - `templates/` - Kubernetes templates
- `Dockerfile` - Container image definition

## Features

- ✅ Express.js HTTP server
- ✅ Health check endpoint (`/health`)
- ✅ Dockerized with multi-stage build
- ✅ Helm charts for easy Kubernetes deployment
- ✅ Auto-scaling with HorizontalPodAutoscaler
- ✅ Ingress support
- ✅ GitHub Actions CI/CD pipeline

## Local Development

### Build Docker image

```bash
docker build -t single-app:latest .
```

### Run Docker container

```bash
docker run -p 3000:3000 -e ENVIRONMENT=development single-app:latest
```

Then visit `http://localhost:3000`

### Deploy with Helm

```bash
helm install myapp ./helm -f ./helm/values.yaml
```

### Verify deployment

```bash
kubectl get pods -n single-app
kubectl get svc -n single-app
kubectl get ingress -n single-app
```

## GitHub Actions Workflow

The `.github/workflows/build-deploy-single-app.yml` workflow:

1. **Build**: Builds a Docker image and pushes to Docker Hub (if relevant secrets are provided)
2. **Test**: Lints and templates the Helm chart
3. **Deploy**: Deploys the app to Kubernetes cluster (if `KUBECONFIG` secret is configured)

### Required Secrets

For full CI/CD automation, add these to your GitHub repository secrets:

- `DOCKER_USERNAME` - Docker Hub username
- `DOCKER_PASSWORD` - Docker Hub personal access token
- `KUBECONFIG` - Base64-encoded kubeconfig (optional; deployment skipped if not provided)

### Setting secrets

```bash
# Base64 encode your kubeconfig
cat ~/.kube/config | base64 -w 0 | pbcopy

# Then add as GitHub secret via web UI or CLI
```

## Environment Variables

The app supports these environment variables:

- `PORT` - Server port (default: 3000)
- `ENVIRONMENT` - Environment name (production/staging/development)
- `APP_VERSION` - Application version

## Results & Output

After pushing code to `main` branch:

1. GitHub Actions automatically builds the Docker image
2. Image gets tagged with branch and commit SHA
3. Image is pushed to Docker Hub (if credentials configured)
4. Helm chart is linted and templated
5. If `KUBECONFIG` is provided, deployment proceeds with rollout verification

Check the workflow logs to see:
- Docker build output
- Image push confirmation
- Helm deployment status
- Kubernetes pod and service status
