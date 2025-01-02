# VPC 2 (Consumer VPC)
resource "aws_vpc" "consumer_vpc" {
  cidr_block = var.consumer_vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true
}

# Subnet 1 (Public)
resource "aws_subnet" "consumer_public_subnet" {
  vpc_id = aws_vpc.consumer_vpc.id
  cidr_block = "10.1.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
}

# Subnet 2 (Private)
resource "aws_subnet" "consumer_private_subnet" {
  vpc_id = aws_vpc.consumer_vpc.id
  cidr_block = "10.1.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = false
}

# Security Group for EC2 Instance
resource "aws_security_group" "consumer_sg" {
  name = "consumer-sg"
  vpc_id = aws_vpc.consumer_vpc.id
}

# EC2 Instance in Consumer VPC
resource "aws_instance" "consumer_ec2" {
  ami = "ami-01816d07b1128cd2d"  # Specify a valid AMI ID
  instance_type = var.ec2_instance_type
  subnet_id = aws_subnet.consumer_private_subnet.id
  vpc_security_group_ids = [aws_security_group.consumer_sg.id]
  key_name = var.key_name
}
