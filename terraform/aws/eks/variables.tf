
variable "project_name" {
  description = "The name of the project."
  type        = string
}

variable "aws_region" {
  description = "The AWS region to deploy the infrastructure to."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC."
  type        = string
}

variable "public_subnets" {
  description = "The IDs of the public subnets."
  type        = list(string)
}

variable "private_subnets" {
  description = "The IDs of the private subnets."
  type        = list(string)
}
