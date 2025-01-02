variable "region" {
  default = "us-east-1"
}

variable "provider_vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "consumer_vpc_cidr" {
  default = "10.1.0.0/16"
}

variable "eks_instance_type" {
  default = "t2.medium"
}

variable "ec2_instance_type" {
  default = "t2.medium"
}

variable "key_name" {
  description = "Key pair name for EC2 access"
  default = "my-key-pair"
}
