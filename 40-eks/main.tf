resource "aws_key_pair" "eks" {
  key_name   = "eks"
  # you can paste the public key directly like this
  #public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL6ONJth+DzeXbU3oGATxjVmoRjPepdl7sBuPzzQT2Nc sivak@BOOK-I6CR3LQ85Q"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDJU30dGg3ihXj7HSH9QG6Juz0MiAgbxpnZjy14Ie/xK0vQyPiBUOy48jUxbfkt1TcHN+fRE5wfniYv9vkT0Q9VPrpMXJeo3mJWBNqp41LUfPkbvxJRjhHmRg+/rlbhD8T1iSwmqzuE7TkuzbyYmsrLwFYgzcQqPeja1G8qUWJcBXJQdmdy6dDZ3u+ZAuLMRE6Rm5POCjSvCG67EXAdIWClIu27XGcoFap6a/+zYXSXfhVcu6FzRRZerW7IgIZ9w2vmNPMjrtdFSQsXe3HgejnwwdY+icLC6dy3TGNTWymFbhAhZDD5WfRJid6vnUZO5l8TDUvuuSQWfs1tPX0hMnjc0uMWWbr/1O6WwqQbYZR6ChhGrc8VzPA2CIwy//K2HmG7s0WnnR+6LGgcIp5h7cDB4NHWf8WOFf2FGwWLVrlJwynT3wq3uWtCY1O0LiFLLFHmn54YvBCsvUzGExxDgm6Ko6ec2rqEYEQhuGF0HVyfbD5e1boJ1bO+TE71qmX3NlhyN7UpKA5awQzJB/mjuMrcAp0h8ZMeTMt4jUwsl5VB32vcOFoxkTpvD5EK1X0f6gC5HROBSPvNoVlfonwAeHx31/c8mPEuhpGljWA8t6a/3csOF2ANNQg9TBd2zc+ovlEpZUy6pwdGruLRywhUEglbaqkktpvNaEyPf9WwUHU/UQ== 91995@saikumarsPC"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"
  #cluster_service_ipv4_cidr = var.cluster_service_ipv4_cidr
  cluster_name    = "${var.project_name}-${var.environment}"
  cluster_version = "1.30"
  # it should be false in PROD environments
  cluster_endpoint_public_access = true

  vpc_id                   = local.vpc_id
  subnet_ids               = split(",", local.private_subnet_ids)
  control_plane_subnet_ids = split(",", local.private_subnet_ids)

  create_cluster_security_group = false
  cluster_security_group_id     = local.cluster_sg_id

  create_node_security_group = false
  node_security_group_id     = local.node_sg_id

  # the user which you used to create cluster will get admin access
  enable_cluster_creator_admin_permissions = true

  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
  }

  eks_managed_node_groups = {
    # blue = {
    #   min_size      = 2
    #   max_size      = 10
    #   desired_size  = 2
    #   capacity_type = "SPOT"
    #   iam_role_additional_policies = {
    #     AmazonEBSCSIDriverPolicy          = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
    #     AmazonElasticFileSystemFullAccess = "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess"
    #     ElasticLoadBalancingFullAccess = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
    #   }
    #   # EKS takes AWS Linux 2 as it's OS to the nodes
    #   key_name = aws_key_pair.eks.key_name
    # }
    green = {
      min_size      = 2
      max_size      = 10
      desired_size  = 2
      capacity_type = "SPOT"
      iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy          = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
        AmazonElasticFileSystemFullAccess = "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess"
        ElasticLoadBalancingFullAccess = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
      }
      # EKS takes AWS Linux 2 as it's OS to the nodes
      key_name = aws_key_pair.eks.key_name
    }
  }

  tags = var.common_tags
}