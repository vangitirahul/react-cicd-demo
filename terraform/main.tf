########################################
# Latest Amazon Linux 2023 AMI
########################################

data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["137112412989"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

########################################
# Default VPC
########################################

data "aws_vpc" "default" {
  default = true
}

########################################
# Default Subnets
########################################

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

########################################
# IAM Role
########################################

resource "aws_iam_role" "ec2_ssm_role" {

  name = "${var.project_name}-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "ec2.amazonaws.com"
      }

      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name = "${var.project_name}-ssm-role"
  }
}

########################################
# Attach Amazon SSM Policy
########################################

resource "aws_iam_role_policy_attachment" "ssm_policy" {

  role = aws_iam_role.ec2_ssm_role.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

########################################
# Instance Profile
########################################

resource "aws_iam_instance_profile" "ec2_profile" {

  name = "${var.project_name}-instance-profile"

  role = aws_iam_role.ec2_ssm_role.name
}

########################################
# Security Group
########################################

resource "aws_security_group" "react_app_sg" {

  name        = "${var.project_name}-sg"
  description = "React CI/CD Security Group"

  vpc_id = data.aws_vpc.default.id

  ingress {
    description = "HTTP"

    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {

    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg"
  }
}

########################################
# EC2 Instance
########################################

resource "aws_instance" "react_server" {

  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  subnet_id = data.aws_subnets.default.ids[0]

  vpc_security_group_ids = [
    aws_security_group.react_app_sg.id
  ]

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  user_data = file("${path.module}/userdata.sh")

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {

    volume_size = 8
    volume_type = "gp3"

    tags = {
      Name = "${var.project_name}-root"
    }
  }

  tags = {

    Name        = var.project_name
    Environment = "Dev"
    ManagedBy   = "Terraform"
  }
}
########################################
# S3 Bucket for Deployment Artifacts
########################################

resource "aws_s3_bucket" "deployment_bucket" {

  bucket = "${var.project_name}-deployment-artifacts"

  force_destroy = true

  tags = {
    Name        = "${var.project_name}-deployment-artifacts"
    Environment = "Dev"
    ManagedBy   = "Terraform"
  }
}

########################################
# Block Public Access
########################################

resource "aws_s3_bucket_public_access_block" "deployment_bucket" {

  bucket = aws_s3_bucket.deployment_bucket.id

  block_public_acls  = true
  ignore_public_acls = true

  block_public_policy     = true
  restrict_public_buckets = true
}
resource "aws_iam_role_policy_attachment" "s3_readonly" {

  role = aws_iam_role.ec2_ssm_role.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}
