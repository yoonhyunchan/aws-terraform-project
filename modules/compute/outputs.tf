output "public_ip" {
  description = "Public IP"
  value       = aws_instance.ec2_instance[*].public_ip
}

output "private_ip" {
  description = "Private IP"
  value       = aws_instance.ec2_instance[*].private_ip
}


output "sg_id" {
  description = "Securoty Group"
  value       = aws_security_group.security_group[*].id
}

