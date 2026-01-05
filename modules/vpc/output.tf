output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.qa_vpc.id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = [
    aws_subnet.qa_private_subnet_1.id,
    aws_subnet.qa_private_subnet_2.id
  ]
}

output "public_subnet_ids" {
  description = "List of private subnet IDs"
  value       = [
    aws_subnet.qa_public_subnet_1.id,
    aws_subnet.qa_public_subnet_2.id
  ]
}


