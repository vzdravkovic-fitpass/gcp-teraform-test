# GCP Terraform GKE Cluster

This Terraform configuration creates a complete Google Kubernetes Engine (GKE) cluster with the following components:

- **VPC Network**: Custom VPC with subnets for the cluster
- **GKE Cluster**: Production-ready cluster with workload identity enabled
- **Node Pool**: Separately managed node pool with autoscaling
- **Service Account**: Dedicated service account for nodes with appropriate IAM roles
- **API Services**: Required Google Cloud APIs are enabled

## Prerequisites

1. **Google Cloud Project**: You need an existing GCP project
2. **Terraform**: Version 1.0 or later installed
3. **Google Cloud SDK**: For authentication (`gcloud` CLI)
4. **Required Permissions**: Your account needs permissions to create GKE clusters and manage IAM

## Quick Start

1. **Clone or navigate to this directory**
   ```bash
   cd /path/to/terraform-gke-project
   ```

2. **Authenticate with Google Cloud**
   ```bash
   gcloud auth login
   gcloud config set project YOUR_PROJECT_ID
   ```

3. **Update Variables**
   Edit `terraform.tfvars` and replace `your-gcp-project-id` with your actual GCP project ID:
   ```bash
   project_id = "your-actual-project-id"
   ```

4. **Initialize Terraform**
   ```bash
   terraform init
   ```

5. **Plan the deployment**
   ```bash
   terraform plan
   ```

6. **Apply the configuration**
   ```bash
   terraform apply
   ```

## Configuration

### Required Variables

- `project_id`: Your GCP project ID (no default - must be provided)

### Optional Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `region` | GCP region for resources | `us-central1` |
| `zone` | GCP zone for resources | `us-central1-a` |
| `cluster_name` | Name of the GKE cluster | `my-gke-cluster` |
| `node_count` | Initial number of nodes | `3` |
| `machine_type` | Machine type for nodes | `e2-medium` |
| `node_service_account_roles` | IAM roles for node service account | See `variables.tf` |

### Network Configuration

- **VPC**: Custom VPC with auto-created subnets disabled
- **Subnet**: Primary subnet with IP range `10.0.0.0/24`
- **Pod Ranges**: Secondary IP range `192.168.64.0/22` for pods
- **Service Ranges**: Secondary IP range `192.168.1.0/24` for services

### Cluster Features

- **Workload Identity**: Enabled for secure authentication
- **Network Policy**: Enabled for pod-to-pod traffic control
- **Horizontal Pod Autoscaling**: Enabled
- **HTTP Load Balancing**: Enabled
- **DNS Cache**: Enabled for better performance
- **Logging**: System components and workloads
- **Monitoring**: System components

### Node Pool Features

- **Autoscaling**: 1-10 nodes based on demand
- **Auto Repair**: Automatic node repair enabled
- **Auto Upgrade**: Automatic node upgrades enabled
- **Preemptible VMs**: Cost-optimized preemptible instances
- **Labels and Tags**: Environment and cluster-specific labels

## Outputs

After deployment, Terraform will output:

- `kubernetes_cluster_name`: Name of the created cluster
- `kubernetes_cluster_host`: Cluster endpoint (sensitive)
- `kubernetes_cluster_ca_certificate`: CA certificate (sensitive)
- `region`: GCP region
- `project_id`: GCP project ID
- `service_account_email`: Node service account email

## Connecting to Your Cluster

After deployment, configure `kubectl` to connect to your cluster:

```bash
gcloud container clusters get-credentials $(terraform output -raw kubernetes_cluster_name) --region $(terraform output -raw region)
```

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

## Security Considerations

1. **Service Account**: The node service account has minimal required permissions
2. **Workload Identity**: Use workload identity for pod-to-GCP service authentication
3. **Network Policies**: Configure network policies for pod traffic control
4. **Secrets Management**: Use GCP Secret Manager or similar for sensitive data

## Cost Optimization

- Uses preemptible VMs for cost savings
- Autoscaling to match workload demands
- e2-medium machine type for development/production balance

## Troubleshooting

### Common Issues

1. **API not enabled**: Ensure required APIs are enabled (Container API, Compute API)
2. **Permissions**: Verify your account has necessary permissions
3. **Quota limits**: Check GCP quotas for your project
4. **Region/Zone**: Ensure selected region/zone is available

### Getting Help

- Check Terraform logs with `TF_LOG=DEBUG terraform apply`
- Review GCP Cloud Console for resource status
- Verify network configuration in VPC section

## File Structure

```
.
├── main.tf              # Main Terraform configuration
├── variables.tf         # Variable definitions
├── outputs.tf           # Output definitions
├── terraform.tfvars     # Variable values (customize this)
├── .gitignore           # Git ignore rules
└── README.md           # This documentation
```

## Next Steps

After deploying the cluster, consider:

1. Installing cluster add-ons (Ingress, monitoring, etc.)
2. Setting up CI/CD pipelines
3. Configuring backup solutions
4. Implementing security policies
5. Setting up monitoring and alerting
