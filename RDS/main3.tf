provider "aws" {
  region = "eu-west-1"
}

resource "aws_vpc" "privatevpc9" {
  cidr_block = "172.24.0.0/16"
  tags = {
    Name = "privatevpc9"
  }
}

resource "aws_subnet" "subnet_a" {
  vpc_id = aws_vpc.privatevpc9.id
  cidr_block = "172.24.1.0/24"
  availability_zone = "eu-west-1a"
}

resource "aws_subnet" "subnet_b" {
  vpc_id = aws_vpc.privatevpc9.id
  cidr_block = "172.24.2.0/24"
  availability_zone = "eu-west-1b"
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name = "dbinstance9"
  description = "DB subnet group for dbinstance9"
  subnet_ids = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]
}

resource "aws_db_instance" "dbinstance9" {
  allocated_storage    = 24
  storage_type         = "gp2"
  engine               = "mariadb"
  engine_version       = "10.4"
  instance_class       = "db.t2.micro"
  name                 = "dbinstance9"
  username             = "dbuser"
  password             = "dbpassword"
  parameter_group_name = "default.mariadb10.4"
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.default.id]
  db_subnet_group_name  = aws_db_subnet_group.db_subnet_group.name
}

resource "aws_security_group" "default" {
  name        = "default"
  description = "Default security group for RDS"
  
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "VPC-ID" {
  value = aws_vpc.privatevpc9.id
}

output "Subnet-ID-A" {
  value = aws_subnet.subnet_a.id
}

output "Subnet-ID-B" {
  value = aws_subnet.subnet_b.id
}

output "RDS-Instance-ID" {
  value = aws_db_instance.dbinstance9.id
}
