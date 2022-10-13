resource "aws_eks_cluster" "eks" {
    name     = "EKS_Demo"
    role_arn = aws_iam_role.eks.arn

    vpc_config {
        subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]
    }

    encryption_config {
        provider {
            key_arn = aws_kms_key.main.arn
        }
        resources = ["secrets"]
    }

    # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
    # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
    depends_on = [
        aws_iam_role_policy_attachment.eks_cluster,
        aws_iam_role_policy_attachment.eks_pods,
    ]
}

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "EKS_Demo_Node_Group"
  node_role_arn   = aws_iam_role.node_group.arn
  subnet_ids      = aws_subnet.private_for_eks_node_group[*].id

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}

output "endpoint" {
  value = aws_eks_cluster.eks.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.eks.certificate_authority[0].data
}
