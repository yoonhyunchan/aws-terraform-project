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

variable "public_web_services" {
  description = "List of public web service names for A records."
  type        = list(string)
  default     = ["harbor", "gitlab", "jenkins"]
}