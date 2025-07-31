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

# -----------------------------------------------------------------------------
#  SSH Key
# -----------------------------------------------------------------------------
module "ssh_key" {
  source                        = "./modules/ssh_key"
}

# -----------------------------------------------------------------------------
#  Networking
# -----------------------------------------------------------------------------
module "networking" {
  source                        = "./modules/networking"
  vpc_cidr                      = var.vpc_cidr
  region                        = var.aws_region
}

# -----------------------------------------------------------------------------
#  IAM Role
# -----------------------------------------------------------------------------
# module "iam" {
#   source                        = "./modules/iam"
# }
data "aws_iam_instance_profile" "instance_profile_name_for_k8s_controller" {
  name = "AWSEC2InstanceProfileForKubernetesController"
}
data "aws_iam_instance_profile" "instance_profile_name_for_k8s_compute" {
  name = "AWSEC2InstanceProfileForKubernetesCompute"
}



# -----------------------------------------------------------------------------
#  EC2 Instances
# -----------------------------------------------------------------------------
locals {
  tags_for_kubernetes = {
    "kubernetes.io/cluster/kubernetes" = "owned"
  }
}

# Bastion Server
module "bastion_server" {
  source                        = "./modules/compute"
  vpc_id                        = module.networking.vpc_id
  ssh_key_name                  = module.ssh_key.ssh_key_name
  subnet_id                     = module.networking.public_subnet_ids[0]
  
  instance_config = {
    count                         = var.bastion_count
    name                          = var.bastion_name
    instance_type                 = var.bastion_instance_type
    volume_size                   = var.bastion_volume_size
    associate_public_ip_address   = true
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
        },
        {
          from_port                 = -1
          to_port                   = -1
          protocol                  = "icmp"
          cidr_blocks               = [var.vpc_cidr]
        },
      ]
    }
  }
}

# Management Server
module "mgmt_server" {
  source                        = "./modules/compute"
  vpc_id                        = module.networking.vpc_id
  ssh_key_name                  = module.ssh_key.ssh_key_name
  subnet_id                     = module.networking.private_subnet_ids[0]
  
  instance_config = {
    count                         = var.mgmt_count
    name                          = var.mgmt_name
    instance_type                 = var.mgmt_instance_type
    volume_size                   = var.mgmt_volume_size
    user_data_extra               = <<-EOF
    echo "Extra user-data starts here"
    dnf install -y ansible
    echo "Clone complete"
  EOF
    security_group = {
      ingress_rules = [
        {
          from_port                 = 22
          to_port                   = 22
          protocol                  = "tcp"
          cidr_blocks               = [var.vpc_cidr]
        },
        {
          from_port                 = 80
          to_port                   = 80
          protocol                  = "tcp"
          cidr_blocks               = [var.vpc_cidr]
        },
        {
          from_port                 = 443
          to_port                   = 443
          protocol                  = "tcp"
          cidr_blocks               = [var.vpc_cidr]
        },
        {
          from_port                 = -1
          to_port                   = -1
          protocol                  = "icmp"
          cidr_blocks               = [var.vpc_cidr]
        },
      ]
    }
  }
}

# Gitlab Server
module "gitlab_server" {
  source                        = "./modules/compute"
  vpc_id                        = module.networking.vpc_id
  ssh_key_name                  = module.ssh_key.ssh_key_name
  subnet_id                     = module.networking.private_subnet_ids[0]
  
  instance_config = {
    count                         = var.gitlab_count
    name                          = var.gitlab_name
    instance_type                 = var.gitlab_instance_type
    volume_size                   = var.gitlab_volume_size
    security_group = {
      ingress_rules = [
        {
          from_port                 = 22
          to_port                   = 22
          protocol                  = "tcp"
          cidr_blocks               = [var.vpc_cidr]
        },
        {
          from_port                 = 80
          to_port                   = 80
          protocol                  = "tcp"
          cidr_blocks               = [var.vpc_cidr]
        },
        {
          from_port                 = 443
          to_port                   = 443
          protocol                  = "tcp"
          cidr_blocks               = [var.vpc_cidr]
        },
        {
          from_port                 = -1
          to_port                   = -1
          protocol                  = "icmp"
          cidr_blocks               = [var.vpc_cidr]
        },
      ]
    }
  }
}

# Jenkins Server
module "jenkins_server" {
  source                        = "./modules/compute"
  vpc_id                        = module.networking.vpc_id
  ssh_key_name                  = module.ssh_key.ssh_key_name
  subnet_id                     = module.networking.private_subnet_ids[0]
  
  instance_config = {
    count                         = var.jenkins_count
    name                          = var.jenkins_name
    instance_type                 = var.jenkins_instance_type
    volume_size                   = var.jenkins_volume_size
    security_group = {
      ingress_rules = [
        {
          from_port                 = 22
          to_port                   = 22
          protocol                  = "tcp"
          cidr_blocks               = [var.vpc_cidr]
        },
        {
          from_port                 = 8080
          to_port                   = 8080
          protocol                  = "tcp"
          cidr_blocks               = [var.vpc_cidr]
        },
        {
          from_port                 = 8443
          to_port                   = 8443
          protocol                  = "tcp"
          cidr_blocks               = [var.vpc_cidr]
        },
        {
          from_port                 = -1
          to_port                   = -1
          protocol                  = "icmp"
          cidr_blocks               = [var.vpc_cidr]
        },
      ]
    }
  }
}

# Jenkins Agent Server
module "jenkins_agent_server" {
  source                        = "./modules/compute"
  vpc_id                        = module.networking.vpc_id
  ssh_key_name                  = module.ssh_key.ssh_key_name
  subnet_id                     = module.networking.private_subnet_ids[0]
  
  instance_config = {
    count                         = var.jenkins_agent_count
    name                          = var.jenkins_agent_name
    instance_type                 = var.jenkins_agent_instance_type
    volume_size                   = var.jenkins_agent_volume_size
    security_group = {
      ingress_rules = [
        {
          from_port                 = 22
          to_port                   = 22
          protocol                  = "tcp"
          cidr_blocks               = [var.vpc_cidr]
        },
        {
          from_port                 = 80
          to_port                   = 80
          protocol                  = "tcp"
          cidr_blocks               = [var.vpc_cidr]
        },
        {
          from_port                 = 443
          to_port                   = 443
          protocol                  = "tcp"
          cidr_blocks               = [var.vpc_cidr]
        },
        {
          from_port                 = -1
          to_port                   = -1
          protocol                  = "icmp"
          cidr_blocks               = [var.vpc_cidr]
        },
      ]
    }
  }
}

# Harbor Server
module "harbor_server" {
  source                        = "./modules/compute"
  vpc_id                        = module.networking.vpc_id
  ssh_key_name                  = module.ssh_key.ssh_key_name
  subnet_id                     = module.networking.private_subnet_ids[0]
  
  instance_config = {
    count                         = var.harbor_count
    name                          = var.harbor_name
    instance_type                 = var.harbor_instance_type
    volume_size                   = var.harbor_volume_size
    security_group = {
      ingress_rules = [
        {
          from_port                 = 22
          to_port                   = 22
          protocol                  = "tcp"
          cidr_blocks               = [var.vpc_cidr]
        },
        {
          from_port                 = 80
          to_port                   = 80
          protocol                  = "tcp"
          cidr_blocks               = [var.vpc_cidr]
        },
        {
          from_port                 = 443
          to_port                   = 443
          protocol                  = "tcp"
          cidr_blocks               = [var.vpc_cidr]
        },
        {
          from_port                 = -1
          to_port                   = -1
          protocol                  = "icmp"
          cidr_blocks               = [var.vpc_cidr]
        },
      ]
    }
  }
}

# Kubernetes Controller Server
module "k8s_controller_server" {
  source                        = "./modules/compute"
  vpc_id                        = module.networking.vpc_id
  ssh_key_name                  = module.ssh_key.ssh_key_name
  subnet_id                     = module.networking.private_subnet_ids[0]
  
  instance_config = {
    count                         = var.k8s_controller_count
    name                          = var.k8s_controller_name
    instance_type                 = var.k8s_controller_instance_type
    volume_size                   = var.k8s_controller_volume_size
    # iam_instance_profile              = module.iam.instance_profile_name_for_k8s_controller.name
    iam_instance_profile              = data.aws_iam_instance_profile.instance_profile_name_for_k8s_controller.name
    tags                          = local.tags_for_kubernetes
    security_group = {
      ingress_rules = [
        {
          from_port                 = 22
          to_port                   = 22
          protocol                  = "tcp"
          cidr_blocks               = [var.vpc_cidr]
        },
        {
          from_port                 = 6443  # Kubernetes API server	All
          to_port                   = 6443
          protocol                  = "tcp"
          cidr_blocks               = [var.vpc_cidr]
        },
        {
          from_port                 = 2379  # etcd server client API	kube-apiserver, etcd
          to_port                   = 2380
          protocol                  = "tcp"
          cidr_blocks               = [var.vpc_cidr]
        },
        {
          from_port                 = 10250 # Kubelet API	Self, Control plane
          to_port                   = 10250
          protocol                  = "tcp"
          cidr_blocks               = [var.vpc_cidr]
        },
        {
          from_port                 = 10259 # kube-scheduler	Self
          to_port                   = 10259
          protocol                  = "tcp"
          cidr_blocks               = [var.vpc_cidr]
        },
        {
          from_port                 = 10257 # kube-controller-manager	Self
          to_port                   = 10257
          protocol                  = "tcp"
          cidr_blocks               = [var.vpc_cidr]
        },
        {
          from_port                 = 5473  # Calico networking with Typha enabled
          to_port                   = 5473
          protocol                  = "tcp"
          cidr_blocks               = [var.vpc_cidr]
        },
        {
          from_port                 = 4789  # Calico networking with VXLAN enabled
          to_port                   = 4789
          protocol                  = "udp"
          cidr_blocks               = [var.vpc_cidr]
        },
        {
          from_port                 = 443 # kube-apiserver host
          to_port                   = 443
          protocol                  = "tcp"
          cidr_blocks               = [var.vpc_cidr]
        },
        # {
        #   from_port                 = 9443 # AWS Loadbalance Controller Webhook Access
        #   to_port                   = 9443
        #   protocol                  = "tcp"
        #   cidr_blocks               = [var.vpc_cidr]
        # },
        {
          from_port                 = 9100 # Prometheus
          to_port                   = 9100
          protocol                  = "tcp"
          cidr_blocks               = [var.vpc_cidr]
        },
        {
          from_port                 = -1
          to_port                   = -1
          protocol                  = "icmp"
          cidr_blocks               = [var.vpc_cidr]
        },
      ]
    }
  }
}

# Kubernetes Compute Server
module "k8s_compute_server" {
  source                        = "./modules/compute"
  vpc_id                        = module.networking.vpc_id
  ssh_key_name                  = module.ssh_key.ssh_key_name
  subnet_id                     = module.networking.private_subnet_ids[0]

  instance_config = {
    count                         = var.k8s_compute_count
    name                          = var.k8s_compute_name
    instance_type                 = var.k8s_compute_instance_type
    volume_size                   = var.k8s_compute_volume_size
    tags                          = local.tags_for_kubernetes
    # iam_instance_profile              = module.iam.instance_profile_name_for_k8s_compute.name
    iam_instance_profile              = data.aws_iam_instance_profile.instance_profile_name_for_k8s_compute.name
    security_group = {
      ingress_rules = [
        {
          from_port                 = 22
          to_port                   = 22
          protocol                  = "tcp"
          cidr_blocks               = [var.vpc_cidr]
        },
        {
          from_port                 = 10250 # Kubelet API	Self, Control plane
          to_port                   = 10250
          protocol                  = "tcp"
          cidr_blocks               = [var.vpc_cidr]
        },
        {
          from_port                 = 10256 # kube-proxy	Self, Load balancers
          to_port                   = 10256
          protocol                  = "tcp"
          cidr_blocks               = [var.vpc_cidr]
        },
        {
          from_port                 = 30000 # NodePort Services†	All
          to_port                   = 32767
          protocol                  = "tcp"
          cidr_blocks               = [var.vpc_cidr]
        },
        {
          from_port                 = 30000 # NodePort Services†	All
          to_port                   = 32767
          protocol                  = "udp"
          cidr_blocks               = [var.vpc_cidr]
        },
        {
          from_port                 = 5473  # Calico networking with Typha enabled
          to_port                   = 5473
          protocol                  = "tcp"
          cidr_blocks               = [var.vpc_cidr]
        },
        {
          from_port                 = 4789  # Calico networking with VXLAN enabled
          to_port                   = 4789
          protocol                  = "udp"
          cidr_blocks               = [var.vpc_cidr]
        },
        {
          from_port                 = 6443 # kube-apiserver host
          to_port                   = 6443
          protocol                  = "tcp"
          cidr_blocks               = [var.vpc_cidr]
        },
        {
          from_port                 = 443  # kube-apiserver host
          to_port                   = 443
          protocol                  = "tcp"
          cidr_blocks               = [var.vpc_cidr]
        },
        # {
        #   from_port                 = 9443 # AWS Loadbalance Controller Webhook Access
        #   to_port                   = 9443
        #   protocol                  = "tcp"
        #   cidr_blocks               = [var.vpc_cidr]
        # },
        {
          from_port                 = 9100  # Prometheus
          to_port                   = 9100
          protocol                  = "tcp"
          cidr_blocks               = [var.vpc_cidr]
        },
        {
          from_port                 = -1
          to_port                   = -1
          protocol                  = "icmp"
          cidr_blocks               = [var.vpc_cidr]
        },
      ]
    }
  }
}

# -----------------------------------------------------------------------------
#  Route 53
# -----------------------------------------------------------------------------

locals {
  all_compute_modules = {
    bastion           = module.bastion_server
    mgmt              = module.mgmt_server
    gitlab            = module.gitlab_server
    jenkins           = module.jenkins_server
    jenkins_agent     = module.jenkins_agent_server
    harbor            = module.harbor_server
    k8s_controller    = module.k8s_controller_server
    k8s_compute       = module.k8s_compute_server
  }
  labeled_private_ips = merge([
    for name, mod_list in local.all_compute_modules : {
      for i, ip in mod_list.private_ip :
      (length(mod_list.private_ip) == 1 ? name : "${name}${i + 1}") => ip
    }
  ]...)
}


module "route53" {
  source                    = "./modules/route53"
  vpc_id                    = module.networking.vpc_id
  public_hosted_zone_name   = var.public_hosted_zone_name
  public_records = {
    for service_name in var.public_web_services :
    service_name => { 
      type    = "A"
      ttl     = 300
      records = [module.bastion_server.public_ip[0]]
    }
  }

  private_hosted_zone_name  = var.private_hosted_zone_name
   private_records = {
    for server_name, server_private_ip in local.labeled_private_ips :
    server_name => {
      type    = "A"
      ttl     = 300
      records = [server_private_ip]
    }
  }
}
