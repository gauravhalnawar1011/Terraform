provider "aws" {
  region = "us-east-2"
}

resource "aws_vpc" "privatevpc2" {
  cidr_block = "172.17.0.0/16"
}

resource "aws_subnet" "subnet_a" {
  count = 1
  vpc_id = aws_vpc.privatevpc2.id
  cidr_block = "172.17.1.0/24"
  availability_zone = "us-east-2a"
}

resource "aws_subnet" "subnet_b" {
  count = 1
  vpc_id = aws_vpc.privatevpc2.id
  cidr_block = "172.17.2.0/24"
  availability_zone = "us-east-2b"
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name        = "my-db-subnet-group"
  description = "My DB Subnet Group"
  subnet_ids  = concat(aws_subnet.subnet_a[*].id, aws_subnet.subnet_b[*].id)
}

resource "aws_db_instance" "mydb" {
  allocated_storage    = 26
  storage_type         = "gp2"
  engine               = "mariadb"
  engine_version       = "10.4"
  instance_class       = "db.t3.micro"
  name                 = "dbinstance2"
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
  value = aws_vpc.privatevpc2.id
}

output "Subnet-ID-A" {
  value = aws_subnet.subnet_a[0].id
}

output "Subnet-ID-B" {
  value = aws_subnet.subnet_b[0].id
}

output "RDS-Instance-ID" {
  value = aws_db_instance.mydb.id
}
