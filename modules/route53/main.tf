data "aws_route53_zone" "my_public_domain" {
  name         = var.public_hosted_zone_name
  private_zone = false
}

resource "aws_route53_record" "public_records" {
  for_each = var.public_records # public_records 맵의 각 항목에 대해 레코드 생성

  zone_id = data.aws_route53_zone.my_public_domain.zone_id
  name    = each.key # 레코드 이름 (예: "www", "api")
  type    = each.value.type
  ttl     = each.value.ttl
  records = each.value.records
}


# resource "aws_route53_record" "www" {
#   for_each = var.service
#   zone_id = data.aws_route53_zone.mydns.zone_id

#   name    = "${each.key}.${aws_route53_zone.mydns.name}"

#   type    = "A"
#   ttl     = 300
#   records = [var.web_server_public_ip]
# }


resource "aws_route53_zone" "private" {
  name         = var.private_hosted_zone_name
  vpc {
    vpc_id = var.vpc_id
  }
}

resource "aws_route53_record" "private_records" {
  for_each = var.private_records # private_records 맵의 각 항목에 대해 레코드 생성

  zone_id = aws_route53_zone.private.zone_id
  name    = each.key # 레코드 이름
  type    = each.value.type
  ttl     = each.value.ttl
  records = each.value.records
}