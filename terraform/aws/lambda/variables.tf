
variable "project_name" {
  description = "The name of the project."
  type        = string
}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket for report uploads."
  type        = string
}

variable "s3_bucket_arn" {
  description = "The ARN of the S3 bucket for report uploads."
  type        = string
}
