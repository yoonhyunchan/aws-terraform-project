resource "aws_security_group" "security_group" {
  name        = "${var.instance_config.name}-sg"
  description = var.security_group_config.description
  vpc_id      = var.vpc_id
  tags        = var.security_group_config.tags
}

resource "aws_vpc_security_group_ingress_rule" "ingress_rules" {
  for_each = {
    for rule in var.security_group_config.ingress_rules :
    "${rule.from_port}-${rule.to_port}-${rule.protocol}" => rule
  }

  security_group_id = aws_security_group.security_group.id
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  ip_protocol       = each.value.protocol

  cidr_ipv4                     = try(each.value.cidr_blocks[0], null)
  referenced_security_group_id = try(each.value.source_sg, null)
  description                  = try(each.value.description, null)
}

resource "aws_vpc_security_group_egress_rule" "egress_rule" {
  security_group_id = aws_security_group.security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}


resource "aws_instance" "ec2_instance" {
  ami                         = var.ami
  instance_type               = var.instance_config.instance_type
  key_name                    = var.ssh_key_name#
  subnet_id                   = var.subnet_id#
  private_ip                  = var.instance_config.private_ip#
  associate_public_ip_address = var.instance_config.associate_public_ip_address#
  vpc_security_group_ids      = [aws_security_group.security_group.id]
  iam_instance_profile        = var.instance_config.iam_instance_profile
  root_block_device {
    volume_size = var.instance_config.volume_size
    volume_type = "gp3"
  }

  user_data = <<-EOF
              #!/bin/bash
              ${var.instance_config.user_data_extra}
              EOF

  tags = merge(
  {  Name = var.instance_config.name },
  var.instance_config.tags
  )
}