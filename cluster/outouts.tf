output "vpc_id" {
  value = aws_vpc.vs_main.id
}

output "vpc_cidr" {
  value = aws_vpc.vs_main.cidr_block
}

output "public_ip" {
  description = "public IP address"
  value       = aws_eip.nat.public_ip
}

output "default_security_group_id" {
  value       = aws_vpc.vs_main.default_security_group_id
}
