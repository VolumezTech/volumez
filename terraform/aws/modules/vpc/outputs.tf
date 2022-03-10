output "vpc_id" {
    value       = aws_vpc.env_vpc.id
    description = "VPC id"
}

output "default_rtb_id" {
    value       = aws_vpc.env_vpc.default_route_table_id
    description = "default route table id"
}