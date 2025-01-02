output "eks_cluster_endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "consumer_ec2_public_ip" {
  value = aws_instance.consumer_ec2.public_ip
}
