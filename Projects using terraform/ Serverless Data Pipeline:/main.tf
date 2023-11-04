# Set your AWS provider configuration
provider "aws" {
  region = "us-east-1" # Set your desired AWS region
}

# Create an S3 bucket to store raw data
resource "aws_s3_bucket" "raw_data_bucket" {
  bucket = "your-raw-data-bucket"
  acl    = "private"
}

# Create an S3 bucket to store processed data
resource "aws_s3_bucket" "processed_data_bucket" {
  bucket = "your-processed-data-bucket"
  acl    = "private"
}

# Create a Lambda function for data ingestion
resource "aws_lambda_function" "data_ingestion_lambda" {
  function_name = "data-ingestion-lambda"
  handler      = "index.handler"
  runtime      = "nodejs14.x"
  role         = aws_iam_role.lambda_execution_role.arn

  # Add your Lambda deployment package (ZIP file) here
  filename     = "path/to/your/lambda-package.zip"
  source_code_hash = filebase64sha256("path/to/your/lambda-package.zip")

  environment {
    variables = {
      RAW_DATA_BUCKET     = aws_s3_bucket.raw_data_bucket.id,
      PROCESSED_DATA_BUCKET = aws_s3_bucket.processed_data_bucket.id
    }
  }
}

# Define an IAM role for Lambda execution
resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda-execution-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Attach policies for S3 access to Lambda execution role
resource "aws_iam_policy_attachment" "lambda_s3_access" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  roles      = [aws_iam_role.lambda_execution_role.name]
}

# Create an event source mapping for Lambda
resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  event_source_arn = aws_s3_bucket.raw_data_bucket.arn
  function_name    = aws_lambda_function.data_ingestion_lambda.function_name
  batch_size       = 10 # Adjust as needed
  starting_position = "LATEST"
}

# Create an AWS Glue job for data transformation
resource "aws_glue_job" "data_transformation_job" {
  name         = "data-transformation-job"
  role_arn     = aws_iam_role.glue_execution_role.arn
  command {
    script_location = "s3://your-data-transformation-script/script.py"
  }
}

# Define an IAM role for AWS Glue job execution
resource "aws_iam_role" "glue_execution_role" {
  name = "glue-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "glue.amazonaws.com"
        }
      }
    ]
  })
}

# Attach policies for S3 and Glue access to Glue execution role
resource "aws_iam_policy_attachment" "glue_s3_access" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  roles      = [aws_iam_role.glue_execution_role.name]
}

resource "aws_iam_policy_attachment" "glue_service_access" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
  roles      = [aws_iam_role.glue_execution_role.name]
}

# Add dependencies for Glue job (e.g., S3 data sources, targets, and connections)
# These depend on your specific data pipeline architecture

# Define Glue triggers for scheduled data processing, if needed

# Add CloudWatch Alarms and Monitoring for pipeline health

# Output the Lambda function and Glue job names/ARNs for use in the pipeline
output "lambda_function" {
  value = aws_lambda_function.data_ingestion_lambda.function_name
}

output "glue_job" {
  value = aws_glue_job.data_transformation_job.name
}
