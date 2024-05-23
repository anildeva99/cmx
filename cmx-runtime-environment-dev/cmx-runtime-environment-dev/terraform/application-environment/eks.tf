#########################
# Application EKS Cluster
#########################
resource "aws_eks_cluster" "application_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_control_plane_role.arn
  version  = var.cluster_k8s_version

  vpc_config {
    subnet_ids         = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
    security_group_ids = [aws_security_group.application_control_plane_sg.id]
  }
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

#########
# Outputs
#########
output "application_cluster_arn" {
  value = aws_eks_cluster.application_cluster.arn
}
