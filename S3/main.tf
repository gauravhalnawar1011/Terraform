provider "aws" {
  region = "us-east-1" # Set your desired AWS region
}

resource "aws_s3_bucket" "example_bucket" {
  bucket = "your-unique-bucket-name"
  acl    = "public-read" # This makes the bucket publicly readable

  versioning {
    enabled = true
  }
}

resource "aws_iam_policy" "bucket_policy" {
  name = "s3-public-read-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = ["s3:GetObject"],
        Effect = "Allow",
        Resource = aws_s3_bucket.example_bucket.arn,
        Principal = "*",
      },
    ]
  })
}

resource "aws_iam_policy_attachment" "attach_policy" {
  policy_arn = aws_iam_policy.bucket_policy.arn
  name       = "s3-public-read-policy-attachment"
  users      = ["arn:aws:iam::aws:policy/AmazonS3FullAccess"] # Attach to your desired IAM users or groups
}

output "bucket_url" {
  value = aws_s3_bucket.example_bucket.website_endpoint
}
