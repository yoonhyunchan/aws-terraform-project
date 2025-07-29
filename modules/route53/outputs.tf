output "private_hosted_zone_name" {
  description = "Private Hosted Zone Name"
  value       = aws_route53_zone.private.name
}