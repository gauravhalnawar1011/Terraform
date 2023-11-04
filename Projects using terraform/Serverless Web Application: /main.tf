# Set your AWS provider configuration
provider "aws" {
  region = "us-east-1" # Set your desired AWS region
}

# Create a DynamoDB table to store application data
resource "aws_dynamodb_table" "app_data" {
  name           = "app-data-table"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"
  attribute {
    name = "id"
    type = "S"
  }
}

# Create a Lambda function for API backend
resource "aws_lambda_function" "api_backend" {
  function_name = "api-backend"
  handler      = "index.handler"
  runtime      = "nodejs14.x"
  role         = aws_iam_role.lambda_execution_role.arn

  # Add your Lambda deployment package (ZIP file) here
  filename     = "path/to/your/lambda-package.zip"
  source_code_hash = filebase64sha256("path/to/your/lambda-package.zip")
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

# Create an API Gateway
resource "aws_api_gateway_rest_api" "web_app_api" {
  name        = "web-app-api"
  description = "Serverless Web Application API"
}

resource "aws_api_gateway_resource" "root" {
  rest_api_id = aws_api_gateway_rest_api.web_app_api.id
  parent_id   = aws_api_gateway_rest_api.web_app_api.root_resource_id
  path_part   = "v1"
}

resource "aws_api_gateway_method" "get" {
  rest_api_id   = aws_api_gateway_rest_api.web_app_api.id
  resource_id   = aws_api_gateway_resource.root.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.web_app_api.id
  resource_id             = aws_api_gateway_resource.root.id
  http_method             = aws_api_gateway_method.get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.api_backend.invoke_arn
}

resource "aws_api_gateway_method_response" "method_response" {
  rest_api_id = aws_api_gateway_rest_api.web_app_api.id
  resource_id = aws_api_gateway_resource.root.id
  http_method = aws_api_gateway_method.get.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  response_models = {
    "application/json" = "Empty"
  }
}
