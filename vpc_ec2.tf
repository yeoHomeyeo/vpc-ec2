locals {
  resource_prefix = "chrisy"
  mykey           = "chrisy-15feb25-keypair"
}

### VPC creation

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"


  name = "${local.resource_prefix}-16feb-vpc" # Change this!!!
  cidr = "10.0.0.0/16"


  azs             = ["${var.myregion_one}a", "${var.myregion_one}b", "${var.myregion_one}c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    Terraform = "true"
  }
}

### latest ami
data "aws_ami" "linux2023" {
  most_recent = true
  filter {
    name   = "name"
    values = ["al2023-ami-2023*x86_64"]
  }
}

### EC2 creation
resource "aws_instance" "public" {
  ami                         = data.aws_ami.linux2023.id #Challenge, find the AMI ID of Amazon Linux 2 in us-east-1
  instance_type               = var.my_inst_type
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  key_name                    = local.mykey #Change to your keyname, e.g. jazeel-key-pair
  vpc_security_group_ids      = [aws_security_group.allow_ssh.id]
  tags = {
    Name = "${local.resource_prefix}-ec2-${var.env}"
  }
}

resource "aws_security_group" "allow_ssh" {
  name        = "${local.resource_prefix}-security-group-ssh"
  description = "Allow SSH inbound"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict this in production!
  }

    ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict this in production!
  }

    ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict this in production!
  }

  egress { # Add this egress block!
    from_port   = 0
    to_port     = 0
    protocol    = "-1"          # Allow all outbound protocols
    cidr_blocks = ["0.0.0.0/0"] # Restrict this in production!
  }
}

