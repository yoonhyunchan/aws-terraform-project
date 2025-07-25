# -----------------------------------------------------------------------------
# Networking Setting
# -----------------------------------------------------------------------------

variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-west-2"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.0.0.0/16"
}

# -----------------------------------------------------------------------------
# Bastion Server Setting
# -----------------------------------------------------------------------------

variable "bastion_name" {
  description = "The name for the Bastion server."
  type        = string
  default     = "bastion_server"
}

variable "bastion_instance_type" {
  description = "The EC2 instance type for the Bastion server."
  type        = string
  default     = "t2.micro"
}

variable "bastion_volume_size" {
  description = "The root volume size (GB) for the Bastion server."
  type        = number
  default     = 30
}

variable "bastion_count" {
  description = "The EC2 Instance Count for the Bastion server."
  type        = number
  default     = 1
}

# -----------------------------------------------------------------------------
# Management Server Setting
# -----------------------------------------------------------------------------
variable "mgmt_name" {
  description = "The name for the Management server."
  type        = string
  default     = "mgmt_server"
}

variable "mgmt_instance_type" {
  description = "The EC2 instance type for the Management server."
  type        = string
  default     = "t2.medium"
}

variable "mgmt_volume_size" {
  description = "The root volume size (GB) for the Management server."
  type        = number
  default     = 30
}

variable "mgmt_count" {
  description = "The EC2 Instance Count for the Management server."
  type        = number
  default     = 1
}

# -----------------------------------------------------------------------------
# Gitlab Server Setting
# -----------------------------------------------------------------------------
variable "gitlab_name" {
  description = "The name for the Gitlab server."
  type        = string
  default     = "gitlab_server"
}

variable "gitlab_instance_type" {
  description = "The EC2 instance type for the Gitlab server."
  type        = string
  default     = "t2.medium"
}

variable "gitlab_volume_size" {
  description = "The root volume size (GB) for the Gitlab server."
  type        = number
  default     = 30
}

variable "gitlab_count" {
  description = "The EC2 Instance Count for the Gitlab server."
  type        = number
  default     = 1
}

# -----------------------------------------------------------------------------
# Jenkins Server Setting
# -----------------------------------------------------------------------------
variable "jenkins_name" {
  description = "The name for the Bastion server."
  type        = string
  default     = "jenkins_server"
}

variable "jenkins_instance_type" {
  description = "The EC2 instance type for the Jenkins server."
  type        = string
  default     = "t2.micro"
}

variable "jenkins_volume_size" {
  description = "The root volume size (GB) for the Jenkins server."
  type        = number
  default     = 30
}

variable "jenkins_count" {
  description = "The EC2 Instance Count for the Jenkins server."
  type        = number
  default     = 1
}

# -----------------------------------------------------------------------------
# Jenkins Agent Server Setting
# -----------------------------------------------------------------------------
variable "jenkins_agent_name" {
  description = "The name for the Jenkins Agent server."
  type        = string
  default     = "jenkins_agent_server"
}

variable "jenkins_agent_instance_type" {
  description = "The EC2 instance type for the Jenkins Agent server."
  type        = string
  default     = "t2.micro"
}

variable "jenkins_agent_volume_size" {
  description = "The root volume size (GB) for the Jenkins Agent server."
  type        = number
  default     = 30
}

variable "jenkins_agent_count" {
  description = "The EC2 Instance Count for the Jenkins Agent server."
  type        = number
  default     = 1
}

# -----------------------------------------------------------------------------
# Harbor Server Setting
# -----------------------------------------------------------------------------
variable "harbor_name" {
  description = "The name for the Harbor server."
  type        = string
  default     = "harbor_server"
}

variable "harbor_instance_type" {
  description = "The EC2 instance type for the Harbor server."
  type        = string
  default     = "t2.micro"
}

variable "harbor_volume_size" {
  description = "The root volume size (GB) for the Harbor server."
  type        = number
  default     = 30
}

variable "harbor_count" {
  description = "The EC2 Instance Count for the Harbor server."
  type        = number
  default     = 1
}

# -----------------------------------------------------------------------------
# Kubernetes Controller Server Setting
# -----------------------------------------------------------------------------
variable "k8s_controller_name" {
  description = "The name for the Kubernetes Controller server."
  type        = string
  default     = "k8s_controller_server"
}

variable "k8s_controller_instance_type" {
  description = "The EC2 instance type for the Kubernetes Controller server."
  type        = string
  default     = "t2.medium"
}

variable "k8s_controller_volume_size" {
  description = "The root volume size (GB) for the Kubernetes Controller server."
  type        = number
  default     = 30
}

variable "k8s_controller_count" {
  description = "The EC2 Instance Count for the Kubernetes Controller server."
  type        = number
  default     = 1
}

# -----------------------------------------------------------------------------
# Kubernetes Compute Server Setting
# -----------------------------------------------------------------------------
variable "k8s_compute_name" {
  description = "The name for the Kubernetes Compute server."
  type        = string
  default     = "k8s_compute_server"
}

variable "k8s_compute_instance_type" {
  description = "The EC2 instance type for the Kubernetes Compute server."
  type        = string
  default     = "t2.medium"
}

variable "k8s_compute_volume_size" {
  description = "The root volume size (GB) for the Kubernetes Compute server."
  type        = number
  default     = 30
}

variable "k8s_compute_count" {
  description = "The EC2 Instance Count for the Kubernetes Compute server."
  type        = number
  default     = 1
}

# -----------------------------------------------------------------------------
# Route53 Setting
# -----------------------------------------------------------------------------
variable "public_hosted_zone_name" {
  description = "The public hosted zone name for public dns"
  type        = string
  default     = ""
}

variable "public_web_services" {
  description = "List of public web service names for A records."
  type        = list(string)
  default     = []
}

variable "private_hosted_zone_name" {
  description = "The public hosted zone name for public dns"
  type        = string
  default     = ""
}



