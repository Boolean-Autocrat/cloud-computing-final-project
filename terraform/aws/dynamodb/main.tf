
resource "aws_dynamodb_table" "main" {
  name           = "${var.project_name}-alerts"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "patient_id"
  range_key      = "timestamp"

  attribute {
    name = "patient_id"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "S"
  }
}
