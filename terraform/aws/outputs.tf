
output "eks_cluster_endpoint" {
  description = "The endpoint for the EKS cluster."
  value       = module.eks.cluster_endpoint
}

output "rds_instance_endpoint" {
  description = "The endpoint for the RDS instance."
  value       = module.rds.db_instance_endpoint
}
