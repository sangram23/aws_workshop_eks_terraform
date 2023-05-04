resource "aws_internet_gateway" "igw" {
  
}
resource "aws_internet_gateway_attachment" "igw_vpc_attach" {
  internet_gateway_id = aws_internet_gateway.igw.id
  vpc_id              = var.vpc_id
}