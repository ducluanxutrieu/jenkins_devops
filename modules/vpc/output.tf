output "vpc_id" {
  value       = aws_vpc.main_vpc.id
  description = "CIDR of main VPC"
}