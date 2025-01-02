provider "aws" {
  region = var.region
}

# VPC 1 (Provider VPC)
resource "aws_vpc" "provider_vpc" {
  cidr_block = var.provider_vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true
}

# Subnet 1 (Private)
resource "aws_subnet" "private_subnet_1" {
  vpc_id = aws_vpc.provider_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = false
  tags = { Name = "PrivateSubnet1" }
}

# Subnet 2 (Private)
resource "aws_subnet" "private_subnet_2" {
  vpc_id = aws_vpc.provider_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = false
  tags = { Name = "PrivateSubnet2" }
}

# Security Group for EKS
resource "aws_security_group" "eks_security_group" {
  name = "eks-sg"
  vpc_id = aws_vpc.provider_vpc.id
}

# IAM Role for EKS
resource "aws_iam_role" "eks_role" {
  name = "eks-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Principal = { Service = "eks.amazonaws.com" }
      Effect = "Allow"
    }]
  })
}

# EKS Cluster
resource "aws_eks_cluster" "eks_cluster" {
  name = "private-eks-cluster"
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
    endpoint_public_access = false
    endpoint_private_access = true
  }
}

# Node Group (Private Node)
resource "aws_launch_configuration" "eks_node_group" {
  name = "eks-node-group"
  image_id = "ami-01816d07b1128cd2d" # Specify a valid AMI ID
  instance_type = var.eks_instance_type
  security_groups = [aws_security_group.eks_security_group.id]
  associate_public_ip_address = false
}

resource "aws_autoscaling_group" "eks_node_group" {
  desired_capacity = 1
  max_size = 2
  min_size = 1
  vpc_zone_identifier = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
  launch_configuration = aws_launch_configuration.eks_node_group.id
}
