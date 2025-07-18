variable "vpc_id" {
  description   = "VPC ID to associate with private hosted zone"
  type          = string
}

variable "ssh_key_name" {
  description                     = "SSH Key Name"
  type                            = string
}

variable "ami" {
  description                     = "AMI"
  type                            = string
}

variable "subnet_id" {
  description                     = "Subnet ID"
  type                            = string
}

variable "instance_config" {
  description = "EC2 instance configuration"
  type = object({
    name                        = string
    instance_type               = string
    private_ip                  = optional(string, null)
    associate_public_ip_address = bool
    volume_size                 = number
    user_data_extra             = optional(string, "")
    iam_instance_profile        = optional(string, null)
    tags                        = optional(map(string), {})
  })
}


variable "security_group_config" {
  description = "Single security group object"
  type = object({
    description    = optional(string, null)
    tags           = optional(map(string), {})
    ingress_rules  = optional(list(object({
      from_port    = number
      to_port      = number
      protocol     = string
      cidr_blocks  = optional(list(string))
      source_sg    = optional(string)
      description  = optional(string)
    })), [])
  })
}

  