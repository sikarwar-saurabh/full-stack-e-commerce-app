resource "aws_eks_cluster" "main" {
  name = var.eks_cluster_name
  role_arn = aws_iam_role.eks_cluster.arn
  version = var.eks_kubernetes_version

  vpc_config {
    subnet_ids = aws_subnet.private[*].id
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]

  tags = {
    Name = "${var.project_name}-${var.environment}-eks"
  }
}

# managed node group
resource "aws_eks_node_group" "main" {
  cluster_name = aws_eks_cluster.main.name

  node_group_name = "${var.project_name}-${var.environment}-nodes"

  node_role_arn = aws_iam_role.eks_node.arn

  subnet_ids = aws_subnet.private[*].id

  instance_types = [
    var.eks_node_instance_type
  ]

  capacity_type = "ON_DEMAND"

  scaling_config {
    desired_size = var.eks_node_desired_size
    min_size = var.eks_node_min_size
    max_size = var.eks_node_max_size
  }

  disk_size = 30

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node,
    aws_iam_role_policy_attachment.eks_cni,
    aws_iam_role_policy_attachment.eks_ecr_read_only
  ]

  tags = {
    Name = "${var.project_name}-${var.environment}-eks-node"
  }
}
