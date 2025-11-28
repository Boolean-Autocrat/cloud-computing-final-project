
resource "aws_s3_bucket" "main" {
  bucket = "${var.project_name}-report-uploads"

  tags = {
    Name        = "${var.project_name}-report-uploads"
    Environment = "Prod"
  }
}
