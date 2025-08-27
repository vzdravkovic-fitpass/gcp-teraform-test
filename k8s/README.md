# Kubernetes Deployment for Fitpass Platform

This directory contains Kubernetes manifests and Terraform configurations to deploy the Fitpass platform on Google Kubernetes Engine (GKE).

## Directory Structure

```
k8s/
├── manifests/              # Raw Kubernetes YAML manifests
│   ├── redis.yaml          # Redis cache deployment
│   ├── php-app.yaml        # PHP application deployment
│   ├── nginx-configmap.yaml # Nginx configuration
│   ├── nginx.yaml          # Nginx reverse proxy deployment
│   └── mailhog.yaml        # Mailhog email testing deployment
├── terraform/              # Terraform Kubernetes provider configuration
│   ├── main.tf             # Main Terraform resources
│   ├── variables.tf        # Variable definitions
│   ├── outputs.tf          # Output definitions
│   ├── terraform.tfvars    # Variable values
│   └── nginx.conf.tpl      # Nginx configuration template
└── README.md               # This file
```

## Deployment Options

### Option 1: Using kubectl (Direct YAML Manifests)

1. **Apply the GKE cluster first:**
   ```bash
   cd ..
   terraform init
   terraform apply
   ```

2. **Get cluster credentials:**
   ```bash
   gcloud container clusters get-credentials fitpass-gke-cluster --region europe-west2
   ```

3. **Deploy applications:**
   ```bash
   cd k8s
   kubectl apply -f .
   ```

4. **Check deployment status:**
   ```bash
   kubectl get pods
   kubectl get services
   ```

5. **Get external IPs:**
   ```bash
   kubectl get services nginx mailhog-web -o wide
   ```

### Option 2: Using Terraform (Recommended)

1. **Deploy GKE cluster first:**
   ```bash
   cd ..
   terraform init
   terraform apply
   ```

2. **Initialize Kubernetes Terraform:**
   ```bash
   cd k8s/terraform
   terraform init
   ```

3. **Set cluster connection variables:**
   ```bash
   # Get outputs from main terraform
   cd ../..
   CLUSTER_ENDPOINT=$(terraform output -raw kubernetes_cluster_host)
   CLUSTER_CA=$(terraform output -raw kubernetes_cluster_ca_certificate)
   
   # Apply Kubernetes resources
   cd k8s/terraform
   terraform apply \
     -var="cluster_endpoint=$CLUSTER_ENDPOINT" \
     -var="cluster_ca_certificate=$CLUSTER_CA"
   ```

4. **Get application URLs:**
   ```bash
   terraform output application_url
   terraform output mailhog_url
   ```

## Application Architecture

### Services Deployed

1. **Redis** (Cache/Session Storage)
   - Internal service on port 6379
   - Used by PHP application for caching

2. **PHP Application** (Main Application)
   - Fitpass platform backend
   - Runs on port 8080
   - Connects to Redis for caching

3. **Nginx** (Reverse Proxy/Web Server)
   - Serves static files and proxies PHP requests
   - **External LoadBalancer** on port 80
   - Main entry point for the application

4. **Mailhog** (Email Testing)
   - SMTP server for development/testing
   - **External LoadBalancer** on port 8025 for web interface
   - Internal SMTP service on port 1025

### Networking

- **Internal Communication**: Services communicate via Kubernetes DNS
- **External Access**: 
  - Main application: `http://<nginx-lb-ip>`
  - Email testing: `http://<mailhog-lb-ip>:8025`

## Configuration

### Environment Variables

The PHP application automatically receives:
- `REDIS_HOST=redis`
- `REDIS_PORT=6379`

### Resource Limits

Default resource allocations:
- **Redis**: 64Mi-128Mi RAM, 50m-100m CPU
- **PHP App**: 256Mi-512Mi RAM, 100m-500m CPU  
- **Nginx**: 64Mi-128Mi RAM, 50m-100m CPU
- **Mailhog**: 64Mi-128Mi RAM, 50m-100m CPU

### Scaling

Adjust replicas in `terraform.tfvars`:
```hcl
fitpass-platform_replicas = 3  # Scale PHP application
nginx_replicas   = 2  # Scale Nginx
```

## Health Checks

All services include:
- **Liveness Probes**: Restart unhealthy containers
- **Readiness Probes**: Remove unhealthy pods from load balancing

## Persistent Storage

Currently using `emptyDir` volumes for simplicity. For production:

1. **Replace emptyDir with PersistentVolumeClaims**
2. **Use Cloud SQL for database** (instead of MySQL in docker-compose)
3. **Use Cloud Storage for static files**

## Security Considerations

1. **Network Policies**: Consider implementing network policies for pod-to-pod communication
2. **Secrets Management**: Use Kubernetes secrets for sensitive data
3. **RBAC**: Configure Role-Based Access Control
4. **Pod Security Standards**: Implement pod security policies

## Monitoring

Monitor your deployment:

```bash
# Check pod status
kubectl get pods -o wide

# Check service endpoints
kubectl get endpoints

# View logs
kubectl logs -f deployment/php-app
kubectl logs -f deployment/nginx
kubectl logs -f deployment/redis

# Check resource usage
kubectl top pods
kubectl top nodes
```

## Troubleshooting

### Common Issues

1. **ImagePullBackOff**: Verify image exists and credentials are configured
2. **CrashLoopBackOff**: Check pod logs for application errors
3. **Pending Pods**: Check node resources and pod requirements
4. **Service Unreachable**: Verify service selectors match pod labels

### Debugging Commands

```bash
# Describe problematic resources
kubectl describe pod <pod-name>
kubectl describe service <service-name>

# Get events
kubectl get events --sort-by=.metadata.creationTimestamp

# Test connectivity
kubectl exec -it deployment/php-app -- curl http://redis:6379
kubectl exec -it deployment/nginx -- curl http://php-app:8080

# Port forward for local testing
kubectl port-forward service/nginx 8080:80
kubectl port-forward service/mailhog-web 8025:8025
```

## Cleanup

Remove all Kubernetes resources:

### Using kubectl:
```bash
cd k8s/manifests
kubectl delete -f .
```

### Using Terraform:
```bash
cd k8s/terraform
terraform destroy
```

## Production Considerations

For production deployment, consider:

1. **Ingress Controller**: Use Nginx Ingress or Google Cloud Load Balancer
2. **TLS/SSL**: Configure HTTPS with cert-manager
3. **Horizontal Pod Autoscaler**: Auto-scale based on CPU/memory
4. **Persistent Volumes**: Use GCE Persistent Disks
5. **Backup Strategy**: Implement backup for persistent data
6. **Monitoring**: Deploy Prometheus/Grafana stack
7. **Logging**: Configure centralized logging with Fluentd/Elasticsearch
