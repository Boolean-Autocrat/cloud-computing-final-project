
output "cluster_endpoint" {
  description = "The endpoint for the EKS cluster."
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_name" {
    description = "The name of the EKS cluster."
    value       = aws_eks_cluster.main.name
}

output "node_group_name" {
    description = "The name of the EKS node group."
    value       = aws_eks_node_group.main.node_group_name
}
