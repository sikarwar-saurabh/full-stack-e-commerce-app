#================
# JENKINS EC2 IAM
#================

# Jenkins IAM role

resource "aws_iam_role" "jenkins" {
  name = "${var.project_name}-${var.environment}-jenkins-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-${var.environment}-jenkins-role"
  }
}


# Jenkins instance profile

resource "aws_iam_instance_profile" "jenkins" {
  name = "${var.project_name}-${var.environment}-jenkins-profile"
  role = aws_iam_role.jenkins.name

  tags = {
    Name = "${var.project_name}-${var.environment}-jenkins-profile"
  }
}


# Jenkins ECR policy

resource "aws_iam_policy" "jenkins_ecr" {
  name = "${var.project_name}-${var.environment}-jenkins-ecr-policy"
  description = "Permissions required by Jenkins to push images to ECR"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid = "ECRAuthorization"
        Effect = "Allow"

        Action = [
          "ecr:GetAuthorizationToken"
        ]

        Resource = "*"
      },
      {
        Sid = "ECRPushPull"
        Effect = "Allow"

        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart",
          "ecr:BatchGetImage"
        ]

        resources = [
                      aws_ecr_repository.app.arn,
                      aws_ecr_repository.migration.arn
      ]
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-${var.environment}-jenkins-ecr-policy"
  }
}

# Attach ECR policy

resource "aws_iam_role_policy_attachment" "jenkins_ecr" {
  role = aws_iam_role.jenkins.name
  policy_arn = aws_iam_policy.jenkins_ecr.arn
}


# Jenkins EKS policy


resource "aws_iam_policy" "jenkins_eks" {
  name = "${var.project_name}-${var.environment}-jenkins-eks-policy"
  description = "Allows Jenkins to describe the EKS cluster"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid = "EKSDescribeCluster"
        Effect = "Allow"

        Action = [
          "eks:DescribeCluster"
        ]

        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-${var.environment}-jenkins-eks-policy"
  }
}

# Attach EKS policy

resource "aws_iam_role_policy_attachment" "jenkins_eks" {
  role = aws_iam_role.jenkins.name
  policy_arn = aws_iam_policy.jenkins_eks.arn
}

#=======
#EC2 IAM
#=======

# EC2 IAM role

resource "aws_iam_role" "ec2" {
  name = "${var.project_name}-${var.environment}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-${var.environment}-ec2-role"
  }
}

# General EC2 instance profile

resource "aws_iam_instance_profile" "ec2" {
  name = "${var.project_name}-${var.environment}-ec2-profile"
  role = aws_iam_role.ec2.name

  tags = {
    Name = "${var.project_name}-${var.environment}-ec2-profile"
  }
}

# SSM Policy for EC2

resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


#EKS Cluster IAM Role

resource "aws_iam_role" "eks_cluster" {
  name = "${var.project_name}-${var.environment}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "eks.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-${var.environment}-eks-cluster-role"
  }
}

#Attach cluster policy

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}


# EKS Node IAM Role
resource "aws_iam_role" "eks_node" {
  name = "${var.project_name}-${var.environment}-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-${var.environment}-eks-node-role"
  }
}


resource "aws_iam_role_policy_attachment" "eks_worker_node" {
  role = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}


resource "aws_iam_role_policy_attachment" "eks_cni" {
  role = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}


resource "aws_iam_role_policy_attachment" "eks_ecr_read_only" {
  role = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
}
