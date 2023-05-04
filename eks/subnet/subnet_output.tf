output "sub-priv1-id" {
  value = aws_subnet.subnet-p1.id
}
output "rtb-priv1-id" {
  value = aws_route_table.rtb_table_eks.id
}
