# IAM Role for EC2 with SSM and EKS Node Scaling Permissions
resource "aws_iam_role" "ec2_ssm_role" {
  name = "ec2_ssm_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach SSM Core Policy
resource "aws_iam_role_policy_attachment" "ssm_core_attachment" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Custom Policy for EKS Node Group Scaling
resource "aws_iam_policy" "eks_node_scaling_policy" {
  name        = "eks_node_scaling_policy"
  description = "Policy to allow EKS node group scaling"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "eks:UpdateNodegroupConfig",
          "eks:DescribeNodegroup",
          "eks:ListNodegroups",
          "eks:ListClusters",
          "eks:DescribeCluster"
        ],
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:UpdateAutoScalingGroup"
        ],
        Resource = "*"
      }
    ]
  })
}

# EKS Policy to the Role
resource "aws_iam_role_policy_attachment" "eks_node_scaling_attachment" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = aws_iam_policy.eks_node_scaling_policy.arn
}

# Instance Profile for EC2
resource "aws_iam_instance_profile" "ec2_ssm_profile" {
  name = "ec2_ssm_profile"
  role = aws_iam_role.ec2_ssm_role.name
}
