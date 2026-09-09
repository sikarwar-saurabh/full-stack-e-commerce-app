output "jenkins_instance_id" {
  description = "Jenkins EC2 instance ID"
  value = aws_instance.jenkins.id
}

output "jenkins_public_ip" {
  description = "Public IP address of Jenkins EC2"
  value = aws_instance.jenkins.public_ip
}

output "jenkins_private_ip" {
  description = "Private IP address of Jenkins EC2"
  value = aws_instance.jenkins.private_ip
}

output "jenkins_instance_profile" {
  description = "Jenkins EC2 instance profile"
  value = aws_iam_instance_profile.jenkins.name
}

output "vpc_id" {
  description = "VPC ID"
  value = aws_vpc.main.id
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value = aws_ecr_repository.app.repository_url
}

output "ecr_repository_arn" {
  description = "ECR repository ARN"
  value = aws_ecr_repository.app.arn
}

output "eks_cluster_name" {
  description = "EKS cluster name"
  value = aws_eks_cluster.main.name
}

output "eks_cluster_endpoint" {
  description = "EKS cluster API endpoint"
  value = aws_eks_cluster.main.endpoint
}

output "eks_cluster_arn" {
  description = "EKS cluster ARN"
  value = aws_eks_cluster.main.arn
}
