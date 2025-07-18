terraform {
  required_providers {
    aws = {
        source                  = "hashicorp/aws"
        version                 = "~> 5.0"
    }
  }
}

provider "aws" {
  region                        = var.aws_region
}

# Data AMI
data "aws_ami" "rhel9" {
  most_recent                   = true
  owners                        = ["309956199498"] # Red Hat 공식 AWS 계정 ID

  filter {
    name                        = "name"
    values                      = ["RHEL-9*_HVM-*"]
  }

  filter {
    name                        = "architecture"
    values                      = ["x86_64"]
  }

  filter {
    name                        = "virtualization-type"
    values                      = ["hvm"]
  }
}

data "aws_ami" "amazon_linux_2023" {
  most_recent                   = true
  owners                        = ["amazon"]

  filter {
    name                        = "name"
    values                      = ["al2023-ami-*-x86_64"]
  }

  filter {
    name                        = "architecture"
    values                      = ["x86_64"]
  }

  filter {
    name                        = "virtualization-type"
    values                      = ["hvm"]
  }
}


# Module SSH Key
module "ssh_key" {
  source                        = "./modules/ssh_key"
}

module "networking" {
  source                        = "./modules/networking"
  vpc_cidr                      = "10.0.0.0/16"
  region                        = var.aws_region
}

module "bastion_server" {
  source                        = "./modules/compute"
  vpc_id                        = module.networking.vpc_id
  ssh_key_name                  = module.ssh_key.ssh_key_name
  subnet_id                     = module.networking.public_subnet_ids[0]
  ami                           = data.aws_ami.amazon_linux_2023.id
  security_group_config         = {
    ingress_rules = [
      {
        from_port                 = 22
        to_port                   = 22
        protocol                  = "tcp"
        cidr_blocks               = ["0.0.0.0/0"]
      },
      {
        from_port                 = 80
        to_port                   = 80
        protocol                  = "tcp"
        cidr_blocks               = ["0.0.0.0/0"]
      },
      {
        from_port                 = 443
        to_port                   = 443
        protocol                  = "tcp"
        cidr_blocks               = ["0.0.0.0/0"]
      }
    ]
  }
  instance_config = {
    name                          = "bastion-server"
    instance_type                 = "t2.micro"
    associate_public_ip_address   = true
    volume_size                   = 30
  }
}



module "route53" {
  source                    = "./modules/route53"
  vpc_id                    = module.networking.vpc_id
  public_hosted_zone_name   = "chanandy.store"
  public_records = {
    "harbor" = {
      type    = "A"
      records = [module.bastion_server.public_ip]
    },
    # "api" = {
    #   type    = "CNAME"
    #   records = ["api.example.com"]
    # }
  }
  private_hosted_zone_name  = "chanandy.internal"
  private_records = {
    # "kubernetes-api" = {
    #   type    = "A"
    #   records = ["10.0.1.10", "10.0.1.11", "10.0.1.12"]
    # },
    bastion = {
      type = "A"
      records = [module.bastion_server.private_ip]
    }
  }
}