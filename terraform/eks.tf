resource "aws_eks_cluster" "eks" {
    name     = "EKS_Demo"
    role_arn = aws_iam_role.eks.arn
    version = "1.23"

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

resource "aws_eks_node_group" "eks_cluster_nodegroup_ondemand" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "eks_cluster_nodegroup_ondemand"
  node_role_arn   = aws_iam_role.node_group.arn
  subnet_ids      = aws_subnet.private_for_eks_node_group[*].id

  labels = {
    type_of_nodegroup = "on_demand_untainted"
  }
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

# https://www.linkedin.com/pulse/eks-cluster-using-terraform-shishir-khandelwal/
resource "aws_eks_node_group" "eks_cluster_nodegroup_spot" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "eks_cluster_nodegroup_spot"
  node_role_arn   = aws_iam_role.node_group.arn
  subnet_ids      = aws_subnet.private_for_eks_node_group[*].id
  capacity_type = "SPOT"
  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }
   
  labels = {
    type_of_nodegroup = "spot_untainted"
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "aws_eks_node_group" "eks_cluster_nodegroup_spot_tainted" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "eks_cluster_nodegroup_spot_tainted"
  node_role_arn   = aws_iam_role.node_group.arn
  subnet_ids      = aws_subnet.private_for_eks_node_group[*].id
  capacity_type = "SPOT"
  instance_types = ["t3a.small"]

  taint {
    key = "jobs"
    value = "true"
    effect = "NO_SCHEDULE"
  }
  labels = {  
     type_of_nodegroup = "spot_tainted"
  }
  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}

output "access_cluster" {
  value = "To access the cluster, run 'aws eks --region us-east-1 update-kubeconfig --name ${aws_eks_cluster.eks.name}'"
}