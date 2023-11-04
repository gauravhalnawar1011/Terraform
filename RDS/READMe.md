# Terraform AWS RDS and VPC Setup

This Terraform script sets up an Amazon Web Services (AWS) Virtual Private Cloud (VPC), creates two subnets in different availability zones, and deploys a MariaDB RDS instance in those subnets.

## Prerequisites

- [Terraform](https://www.terraform.io/) installed on your local machine.
- AWS CLI configured with valid access credentials.

## Instructions

1. Clone this repository to your local machine.

2. Navigate to the project directory:

# Execute Terraform commands
variable "aws_access_key" {}
variable "aws_secret_key" {}

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = "us-east-2"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.0"
    }
  }
}

# Initialize the working directory
terraform init

# Plan the infrastructure changes
terraform plan

# Apply the changes to create the AWS resources
terraform apply

# After the resources are created, Terraform will display the RDS instance endpoint in the output.

# You can access the RDS instance using the provided endpoint.

# To destroy the resources when no longer needed:
terraform destroy
