# https://docs.aws.amazon.com/eks/latest/userguide/service_IAM_role.html#create-service-role
resource "aws_iam_role" "eks" {
    name                = "eksClusterRole"
    description         = "Amazon EKS - Cluster role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
        {
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Sid    = ""
            Principal = {
                Service = "eks.amazonaws.com"
            }
        },
        ]
    })
}

resource "aws_iam_role_policy_attachment" "eks_cluster" {
    role       = aws_iam_role.eks.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource "aws_iam_role_policy_attachment" "eks_pods" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
    role       = aws_iam_role.eks.name
}

resource "aws_iam_role" "node_group" {
  name = "eks-node-group"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_group.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_group.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_group.name
}