
variable "project_name" {
  description = "The name of the project."
  type        = string
}

variable "private_subnets" {
  description = "The IDs of the private subnets."
  type        = list(string)
}

variable "db_username" {
  description = "The username for the RDS database."
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "The password for the RDS database."
  type        = string
  sensitive   = true
}

variable "vpc_id" {
  type = string
}
