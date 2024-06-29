# Configure AWS provider
provider "aws" {
  region = "us-east-1"  # Update with your desired AWS region
}

# Define VPC
resource "aws_vpc" "main_vpc" {
  cidr_block           = "172.31.0.0/16"  # Update with your desired VPC CIDR block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Main VPC"
  }
}

# Define subnet(s)
resource "aws_subnet" "eks_subnet1" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "172.31.16.0/20"  # Update with your desired subnet CIDR block for AZ 1
  availability_zone = "us-east-1a"  # Update with your desired Availability Zone

  tags = {
    Name = "EKS Subnet 1"
  }
}

resource "aws_subnet" "eks_subnet2" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "172.31.32.0/20"  # Update with your desired subnet CIDR block for AZ 2
  availability_zone = "us-east-1b"  # Update with your desired Availability Zone

  tags = {
    Name = "EKS Subnet 2"
  }
}

# Define IAM role for EKS service
resource "aws_iam_role" "eks_role" {
  name = "eks-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Define EKS cluster
resource "aws_eks_cluster" "eks_cluster" {
  name     = "my-cluster"
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.eks_subnet1.id,
      aws_subnet.eks_subnet2.id,
      # Add more subnet IDs from different AZs if needed
    ]

    # Other configurations can be added here if needed
    # For example:
    # cluster_security_group_id = aws_security_group.eks_cluster_sg.id
    # endpoint_private_access = false
    # endpoint_public_access = true
    # public_access_cidrs = ["0.0.0.0/0"]
  }

  depends_on = [aws_iam_role.eks_role]  # Ensure IAM role is created before EKS cluster
}

# Output EKS cluster details
output "eks_cluster_name" {
  value = aws_eks_cluster.eks_cluster.name
}
