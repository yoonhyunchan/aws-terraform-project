output "vpc_id" {
  value = module.networking.vpc_id
}

output "region" {
  value = var.aws_region
}

output "bastion_public_ip" {
  value = module.bastion_server.public_ip[0]
}
output "server_names" {
  value = keys(local.labeled_private_ips)
}