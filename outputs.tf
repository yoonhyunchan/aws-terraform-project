output "vpc_id" {
  value = module.networking.vpc_id
  sensitive = true
}

output "region" {
  value = var.aws_region
  sensitive = true
}

output "bastion_public_ip" {
  value = module.bastion_server.public_ip[0]
  sensitive = true
}

output "server_names" {
  value = keys(local.labeled_private_ips)
  sensitive = true
}

output "private_hosted_zone_name" {
  value = module.route53.private_hosted_zone_name
  sensitive = true
}