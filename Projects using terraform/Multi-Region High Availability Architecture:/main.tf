# Set your AWS provider configuration
provider "aws" {
  region = "us-east-1" # Primary region
}

# Define the secondary AWS provider configuration for another region
provider "aws" {
  alias  = "secondary"
  region = "us-west-2" # Secondary region
}

# Create a Virtual Private Cloud (VPC) in the primary region
resource "aws_vpc" "primary_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create a VPC in the secondary region
resource "aws_vpc" "secondary_vpc" {
  provider   = aws.secondary
  cidr_block = "10.1.0.0/16"
}

# Create a public subnet in the primary region
resource "aws_subnet" "primary_subnet" {
  vpc_id     = aws_vpc.primary_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
}

# Create a public subnet in the secondary region
resource "aws_subnet" "secondary_subnet" {
  provider   = aws.secondary
  vpc_id     = aws_vpc.secondary_vpc.id
  cidr_block = "10.1.1.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = true
}

# Create an Elastic Load Balancer (ELB) in the primary region
resource "aws_lb" "primary_lb" {
  name               = "primary-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.primary_subnet.id]
}

# Create an ELB in the secondary region
resource "aws_lb" "secondary_lb" {
  provider           = aws.secondary
  name               = "secondary-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.secondary_subnet.id]
}

# Define a Route 53 health check for primary LB
resource "aws_route53_health_check" "primary_health_check" {
  port               = 80
  type               = "HTTP"
  resource_path      = "/health"
  failure_threshold  = 3
  request_interval   = 10
  measure_latency    = true
  enable_sni         = false
  inverted           = false
}

# Define Route 53 DNS record for failover between primary and secondary
resource "aws_route53_record" "failover" {
  name = "example.com"
  type = "A"

  alias {
    name                   = aws_lb.primary_lb.dns_name
    zone_id                = aws_lb.primary_lb.zone_id
    evaluate_target_health = true
  }

  health_check_id = aws_route53_health_check.primary_health_check.id
}
