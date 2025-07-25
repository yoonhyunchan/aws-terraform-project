variable "vpc_id" {
  description   = "VPC ID to associate with private hosted zone"
  type          = string
}

variable "public_hosted_zone_name" {
  description = "The name of the existing public Route 53 hosted zone (e.g., example.com)."
  type        = string
  default     = null
}

variable "public_records" {
  description = "A map of public records to add to the existing public hosted zone."
  type = map(object({
    type    = string
    ttl     = optional(number, 300)
    records = list(string)
  }))
  default = {}
}

variable "private_hosted_zone_name" {
  description = "The name for the new private Route 53 hosted zone (e.g., internal.example.com)."
  type        = string
  default     = null
}

variable "private_records" {
  description = "A map of private records to add to the new private hosted zone."
  type = map(object({
    type    = string
    ttl     = optional(number, 300)
    records = list(string)
  }))
  default = {}
}