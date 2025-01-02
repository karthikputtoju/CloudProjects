# Declare the Network Load Balancer
resource "aws_lb" "nlb" {
  name               = "my-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = [aws_subnet.consumer_private_subnet.id, aws_subnet.consumer_public_subnet.id]
}

# Target Group for NLB
resource "aws_lb_target_group" "nlb_tg" {
  name     = "my-nlb-tg"
  port     = 443
  protocol = "TCP"
  vpc_id   = aws_vpc.consumer_vpc.id
}

# NLB Listener for HTTPS (port 443)
resource "aws_lb_listener" "nlb_listener" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = "443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb_tg.arn
  }
}

# VPC Endpoint Service (EKS API)
resource "aws_vpc_endpoint_service" "eks_service" {
  private_dns_name = "eks-api.private"
  acceptance_required = false
  network_load_balancer_arns = [aws_lb.nlb.arn]  # Use the declared load balancer ARN
}

# VPC Endpoint in Consumer VPC
resource "aws_vpc_endpoint" "private_link" {
  vpc_id            = aws_vpc.consumer_vpc.id
  service_name      = aws_vpc_endpoint_service.eks_service.service_name
  vpc_endpoint_type = "Interface"  # Specify the correct endpoint type
  subnet_ids        = [aws_subnet.consumer_private_subnet.id, aws_subnet.consumer_public_subnet.id]
  security_group_ids = [aws_security_group.consumer_sg.id]
  private_dns_enabled = false  # Disable private DNS
}

# Internet Gateway and Route Table for Public Subnet
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.consumer_vpc.id
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.consumer_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public_rt_assoc" {
  subnet_id      = aws_subnet.consumer_public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}
