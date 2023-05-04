resource "tls_private_key" "public_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ec2_key_public" {
  key_name   = "public_access_key"
  public_key = tls_private_key.public_key.public_key_openssh
}