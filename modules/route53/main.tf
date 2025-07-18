# Route53 Public Hosted Zone 
data "aws_route53_zone" "my_public_domain" {
  name         = var.public_hosted_zone_name
  private_zone = false
}

resource "aws_route53_record" "public_records" {
  for_each = var.public_records # public_records 맵의 각 항목에 대해 레코드 생성

  zone_id = data.aws_route53_zone.my_public_domain.zone_id
  name    = each.key
  type    = each.value.type
  ttl     = each.value.ttl
  records = each.value.records
}

# Route53 Private Hosted Zone 
resource "aws_route53_zone" "private" {
  name         = var.private_hosted_zone_name
  vpc {
    vpc_id = var.vpc_id
  }
}

resource "aws_route53_record" "private_records" {
  for_each = var.private_records

  zone_id = aws_route53_zone.private.zone_id
  name    = each.key
  type    = each.value.type
  ttl     = each.value.ttl
  records = each.value.records
}