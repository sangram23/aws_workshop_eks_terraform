output "public_subnet_arn" {
    value = aws_subnet.public_subnet.arn
}
output "public_subnet_id" {
    value = aws_subnet.public_subnet.id
}
output "public_subne_route_table_arn" {
    value = aws_route_table.public_subne_route_table.arn
  
}
output "public_subne_route_table_id" {
    value = aws_route_table.public_subne_route_table.id
  
}