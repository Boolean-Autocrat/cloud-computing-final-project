# HealthMonitor

This is a multi-cloud microservices application for monitoring patient vitals.

## How to Run

### 1. Provision Infrastructure

1.  Navigate to the `terraform/aws` directory.
2.  Initialize Terraform: `terraform init`
3.  Apply the Terraform configuration: `terraform apply`

4.  Navigate to the `terraform/gcp` directory.
5.  Initialize Terraform: `terraform init`
6.  Apply the Terraform configuration: `terraform apply`

7.  Navigate to the `terraform/kafka` directory.
8.  Initialize Terraform: `terraform init`
9.  Apply the Terraform configuration: `terraform apply`

### 2. Deploy via ArgoCD

1.  Make sure you have an ArgoCD instance running in your EKS cluster.
2.  Update the `repoURL` in `k8s-manifests/argocd-apps/health-monitor-app.yaml` to point to your Git repository.
3.  Apply the ArgoCD application manifest: `kubectl apply -f k8s-manifests/argocd-apps/health-monitor-app.yaml`

ArgoCD will then automatically sync the Kubernetes manifests from the Git repository to the EKS cluster.
