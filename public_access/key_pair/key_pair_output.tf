output "ec2_key_public_arn" {
   value=aws_key_pair.ec2_key_public.arn
  
}
output "ec2_key_public_id" {
   value=aws_key_pair.ec2_key_public.id
  
}
output "ec2_key_public_key_name" {
   value=aws_key_pair.ec2_key_public.key_name
  
}
output "ec2_key_public_key_pair_id" {
   value=aws_key_pair.ec2_key_public.key_pair_id
  
}

output "ec2_key_public_fingerprint" {
  value=aws_key_pair.ec2_key_public.fingerprint
}