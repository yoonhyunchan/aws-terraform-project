output "vpc_id" {
  value = module.networking.vpc_id
}

output "region" {
  value = module.networking.vpc_id
}

output "bastion_public_ip" {
  value = module.bastion_server.public_ip
}