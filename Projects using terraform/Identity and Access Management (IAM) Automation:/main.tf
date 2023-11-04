# Set your AWS provider configuration
provider "aws" {
  region = "us-east-1" # Set your desired AWS region
}

# Define an IAM policy for S3 read-only access
resource "aws_iam_policy" "s3_read_policy" {
  name = "s3-read-policy"

  description = "Provides read-only access to S3 buckets"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "s3:GetObject",
        Effect   = "Allow",
        Resource = "arn:aws:s3:::your-bucket-name/*"
      }
    ]
  })
}

# Define an IAM policy for EC2 full access
resource "aws_iam_policy" "ec2_full_access_policy" {
  name = "ec2-full-access-policy"

  description = "Provides full access to EC2 instances"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "ec2:*",
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

# Define an IAM role for EC2 instances with the EC2 full access policy
resource "aws_iam_role" "ec2_role" {
  name = "ec2-instance-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach the EC2 full access policy to the IAM role
resource "aws_iam_policy_attachment" "ec2_policy_attachment" {
  name = "ec2-policy-attachment"
  policy_arn = aws_iam_policy.ec2_full_access_policy.arn
  groups     = [aws_iam_role.ec2_role.name]
}

# Create an IAM user and attach the S3 read-only policy
resource "aws_iam_user" "s3_user" {
  name = "s3-user"
}

resource "aws_iam_user_policy_attachment" "s3_user_policy_attachment" {
  policy_arn = aws_iam_policy.s3_read_policy.arn
  user       = aws_iam_user.s3_user.name
}
