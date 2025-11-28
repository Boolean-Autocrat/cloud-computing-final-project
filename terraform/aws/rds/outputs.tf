
output "db_instance_endpoint" {
  description = "The endpoint for the RDS instance."
  value       = aws_db_instance.main.endpoint
}
