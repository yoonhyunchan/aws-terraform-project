<p align="center">
    <!-- <img src="https://skillicons.dev/icons?i=ansible,gitlab,jenkins,harbor" /> -->
    <img src="https://raw.githubusercontent.com/yoonhyunchan/yoonhyunchan/refs/heads/main/logos/terraform-auto.svg" width="46"/>
    <img src="https://raw.githubusercontent.com/yoonhyunchan/yoonhyunchan/refs/heads/main/logos/aws-auto.svg" width="46"/>
    <img src="https://raw.githubusercontent.com/yoonhyunchan/yoonhyunchan/refs/heads/main/logos/gitlab-auto.svg" width="46"/>
    <img src="https://raw.githubusercontent.com/yoonhyunchan/yoonhyunchan/refs/heads/main/logos/jenkins-auto.svg" width="46"/>
    <img src="https://raw.githubusercontent.com/yoonhyunchan/yoonhyunchan/refs/heads/main/logos/harbor-auto.svg" width="46"/>
    <img src="https://raw.githubusercontent.com/yoonhyunchan/yoonhyunchan/refs/heads/main/logos/kubernetes.svg" width="46"/>
</p>

# Terraform DevOps & Kuberntes Infrastructure

This Terraform project deploys a complete DevOps infrastructure on AWS, including CI/CD tools, container registry, and Kubernetes cluster with proper networking and security configurations.

## 🚪 Next Step
**[Ansible for Kubernetes Repository](https://github.com/yoonhyunchan/kubernetes-ansible)** - My Repo<br>
**[Ansible for CICD Repository](https://github.com/yoonhyunchan/cicd-ansible)** - My Repo

**[[Devops] 05. Gitlab&Jenkins&Harbor Integration (1)
](https://mon-roman.tistory.com/entry/Devops-04-GitlabJenkinsHarbor-Integration-1)** - My Blog Post<br>
**[[Devops] 06. Gitlab&Jenkins&Harbor Integration (2)
](https://mon-roman.tistory.com/entry/Devops-06-GitlabJenkinsHarbor-Integration-2)** - My Blog Post<br>
**[[Devops] 07. Gitlab&Jenkins&Harbor Integration (3)
](https://mon-roman.tistory.com/entry/Devops-07-GitlabJenkinsHarbor-Integration-3)** - My Blog Post<br>

## 🏗️ Infrastructure Overview

### Core Infrastructure
- **VPC** with public and private subnets across multiple availability zones with tags for kubernetes Environment
- **SSH Key Pair** for secure server access
- **Route53** DNS configuration for both public and private zones
- **Compute** EC2 Instance & Security Group configuration
- **IAM Roles** for Kubernetes cluster management

### Server Components

| Server Type        | Purpose                       | Instance Type | Network | Count |
| ------------------ | ----------------------------- | ------------- | ------- | ----- |
| **Bastion**        | Jump server for secure access | t2.micro      | Public  | 1     |
| **Management**     | Ansible control node          | t2.medium     | Private | 1     |
| **GitLab**         | Source code management        | t2.medium     | Private | 1     |
| **Jenkins**        | CI/CD pipeline server         | t2.micro      | Private | 1     |
| **Jenkins Agent**  | CI/CD build executor          | t2.micro      | Private | 2     |
| **Harbor**         | Container registry            | t2.micro      | Private | 1     |
| **K8s Controller** | Kubernetes control plane      | t2.medium     | Private | 1     |
| **K8s Compute**    | Kubernetes worker nodes       | t2.medium     | Private | 2     |

### Server-Specific Prerequisites & Requirements

#### 🔐 Bastion Server
- **Security Group**: 
  - SSH (22) from 0.0.0.0/0 (Test)
  - HTTP (80) from 0.0.0.0/0 (Test)
  - HTTPS (443) from 0.0.0.0/0 (Test)
  - ICMP from VPC CIDR
- **Network**: Public subnet with auto-assigned public IP
- **Purpose**: Secure jump host for accessing private resources

#### 🛠️ Management Server
- **Security Group**:
  - SSH (22) from VPC CIDR
  - HTTP (80) from VPC CIDR
  - HTTPS (443) from VPC CIDR
  - ICMP from VPC CIDR
- **Network**: Private subnet
- **Purpose**: Infrastructure automation and management

#### 📦 GitLab Server
- **Security Group**:
  - SSH (22) from VPC CIDR
  - HTTP (80) from VPC CIDR
  - HTTPS (443) from VPC CIDR
  - ICMP from VPC CIDR
- **Network**: Private subnet
- **Recommended**: t2.medium or larger for production
- **Purpose**: Source code repository and CI/CD

#### 🔄 Jenkins Server
- **Security Group**:
  - SSH (22) from VPC CIDR
  - Jenkins Web UI (8080) from VPC CIDR
  - Jenkins HTTPS (8443) from VPC CIDR
  - ICMP from VPC CIDR
- **Network**: Private subnet
- **Purpose**: CI/CD pipeline orchestration

#### ⚙️ Jenkins Agent Server
- **Security Group**:
  - SSH (22) from VPC CIDR
  - HTTP (80) from VPC CIDR
  - HTTPS (443) from VPC CIDR
  - ICMP from VPC CIDR
- **Network**: Private subnet
- **Purpose**: Build and test execution for Jenkins pipelines

#### 🐳 Harbor Server
- **Security Group**:
  - SSH (22) from VPC CIDR
  - HTTP (80) from VPC CIDR
  - HTTPS (443) from VPC CIDR
  - ICMP from VPC CIDR
- **Network**: Private subnet
- **Purpose**: Container image registry and management

#### 🎛️ Kubernetes Controller Server
- **Security Group**:
  - SSH (22) from VPC CIDR
  - Kubernetes API (6443) from VPC CIDR
  - etcd (2379-2380) from VPC CIDR
  - Kubelet API (10250) from VPC CIDR
  - kube-scheduler (10259) from VPC CIDR
  - kube-controller-manager (10257) from VPC CIDR
  - Calico networking (5473, 4789) from VPC CIDR
  - Prometheus metrics (9100) from VPC CIDR
  - ICMP from VPC CIDR
- **IAM Role**: `AWSEC2InstanceProfileForKubernetesController`
- **Network**: Private subnet
- **Tags**: Kubernetes cluster ownership tags (important for AWS kuberntetes Add-ons like aws-loadbalancer-controller, ...)
- **Purpose**: Kubernetes control plane components

#### 🖥️ Kubernetes Compute Server
- **Security Group**:
  - SSH (22) from VPC CIDR
  - Kubelet API (10250) from VPC CIDR
  - kube-proxy (10256) from VPC CIDR
  - NodePort Services (30000-32767) from VPC CIDR
  - Calico networking (5473, 4789) from VPC CIDR
  - Kubernetes API (6443, 443) from VPC CIDR
  - Prometheus metrics (9100) from VPC CIDR
  - ICMP from VPC CIDR
- **IAM Role**: `AWSEC2InstanceProfileForKubernetesCompute`
- **Network**: Private subnet
- **Tags**: Kubernetes cluster ownership tags (important for AWS kuberntetes Add-ons like aws-loadbalancer-controller, ...)
- **Purpose**: Kubernetes worker nodes for application workloads


## 🚀 Quick Start

### Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate credentials

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yoonhyunchan/aws-terraform-project.git
   cd clean
   ```

2. **Configure variables**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your specific values
   ## if Not use Route53 public DNS, Don't Enter "public_hosted_zone_name" and "public_web_services"
   ## And Recommended "private_hosted_zone_name"
   ```

3. **Configure AWS credentials**
   ```bash
   aws configure
   # Input Your AWS Credentials
   ```

4. **Configure IAM Role**
   ```bash
   # If You Run First, and Don't have IAM Role for k8s, in main.tf
   
   module "iam" {
   source                        = "./modules/iam"
   }

   # Else
   
   data "aws_iam_instance_profile" "instance_profile_name_for_k8s_controller" {
   name = "AWSEC2InstanceProfileForKubernetesController"
   }

   data "aws_iam_instance_profile" "instance_profile_name_for_k8s_compute" {
   name = "AWSEC2InstanceProfileForKubernetesCompute"
   }

   ```

5. **Deploy infrastructure**
   ```bash
   # Option 1: Use the automated script
   chmod +x script.sh
   ./script.sh
   
   # Option 2: Manual deployment
   terraform init
   terraform plan
   terraform apply
   ```

## ⚙️ Configuration

### Required Variables

Edit `terraform.tfvars` to customize your deployment:

```hcl
# Networking
aws_region = "us-west-2"
vpc_cidr   = "10.0.0.0/16"

# DNS Configuration
public_hosted_zone_name  = "yourdomain.com"
private_hosted_zone_name = "yourdomain.internal"

# Server configurations
bastion_name                  = "bastion_server"
bastion_instance_type         = "t2.micro"
bastion_volume_size           = 30
bastion_count                 = 1
# ... other server configurations
```

### Key Configuration Options

- **Instance Types**: Adjust based on your workload requirements
- **Volume Sizes**: Modify storage capacity for each server
- **Instance Counts**: Scale the number of instances per server type
- **DNS Zones**: Configure your domain names for public and private zones

## 🔧 Module Structure

```
modules/
├── compute/         # EC2 instance management
├── iam/             # IAM roles and policies
├── networking/      # VPC, subnets, and security groups
├── route53/         # DNS configuration
└── ssh_key/         # SSH key pair management
```


## 📊 Outputs

After deployment, the following information is available:

```bash
terraform output
```

Key outputs include:
- VPC ID and region
- Bastion server public IP
- Server names and private IPs
- DNS zone information


## 🧹 Cleanup

To destroy the infrastructure:

```bash
terraform destroy
```

## 📝 Notes

- Kubernetes nodes are configured with proper IAM roles for AWS integration
- All servers use Amazon Linux 2
- Security groups are configured for specific service requirements
- DNS records are automatically created for all servers
