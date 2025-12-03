
# Zip the lambda function code
data "archive_file" "zipit" {
  type        = "zip"
  source_dir  = "${path.module}/../../../src/report-parser-lambda"
  output_path = "${path.module}/report-parser-lambda.zip"
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_exec_role" {
  name = "${var.project_name}-lambda-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Attach basic execution role
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# S3 GetObject policy
resource "aws_iam_policy" "s3_get_object_policy" {
  name        = "${var.project_name}-s3-get-object-policy"
  description = "Policy to allow Lambda to get objects from the S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action   = "s3:GetObject",
      Effect   = "Allow",
      Resource = "${var.s3_bucket_arn}/*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "s3_get_object_attachment" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.s3_get_object_policy.arn
}

# Lambda Function
resource "aws_lambda_function" "report_parser" {
  filename      = data.archive_file.zipit.output_path
  function_name = "${var.project_name}-report-parser"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "main.lambda_handler"
  runtime       = "python3.9"
  source_code_hash = data.archive_file.zipit.output_base64sha256

  environment {
    variables = {
      S3_BUCKET_NAME = var.s3_bucket_name
    }
  }
}

# S3 Bucket Notification
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = var.s3_bucket_name

  lambda_function {
    lambda_function_arn = aws_lambda_function.report_parser.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "uploads/"
    filter_suffix       = ".pdf"
  }

  depends_on = [aws_lambda_permission.s3_invoke]
}

# Lambda Permission for S3 invocation
resource "aws_lambda_permission" "s3_invoke" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.report_parser.arn
  principal     = "s3.amazonaws.com"
  source_arn    = var.s3_bucket_arn
}
