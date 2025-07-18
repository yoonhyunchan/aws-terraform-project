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


# Module SSH Key
module "ssh_key" {
  source                        = "./modules/ssh_key"
}

module "networking" {
  source                        = "./modules/networking"
  vpc_cidr                      = var.vpc_cidr
  region                        = var.aws_region
}

module "bastion_server" {
  source                        = "./modules/compute"
  vpc_id                        = module.networking.vpc_id
  ssh_key_name                  = module.ssh_key.ssh_key_name
  subnet_id                     = module.networking.public_subnet_ids[0]
  
  instance_config = {
    name                          = "bastion-server"
    instance_type                 = "t2.micro"
    associate_public_ip_address   = true
    volume_size                   = 30
    security_group = {
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
  }
}



module "route53" {
  source                    = "./modules/route53"
  vpc_id                    = module.networking.vpc_id
  public_hosted_zone_name   = "chanandy.store"
  public_records = {
    
    for service_name in var.public_web_services :
    service_name => { 
      type    = "A"
      ttl     = 300
      records = [module.bastion_server.public_ip]
    }
  }

  private_hosted_zone_name  = "chanandy.internal"
  private_records = {
    bastion = {
      type = "A"
      records = [module.bastion_server.private_ip]
    }
  }
}