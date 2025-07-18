# ssh-keygen -t rsa -b 4096 -f ~/.ssh/terraform-key
# resource "aws_key_pair" "imported" {
#   key_name   = "terraform-key"
#   public_key = file("~/.ssh/terraform-key.pub")
# }


resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated" {
  key_name   = "terraform-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

resource "local_file" "private_key_pem" {
  content  = tls_private_key.ssh_key.private_key_pem
  # filename = "/Users/yoonhyunchan/.ssh/terraform-key.pem"
  # filename = "${path.home}/.ssh/${aws_key_pair.generated.key_name}.pem"
  filename = pathexpand("~/.ssh/${aws_key_pair.generated.key_name}.pem")
  file_permission = "0400"
}