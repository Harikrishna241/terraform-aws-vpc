output "vpc_id" {
    value = aws_vpc.expense.id
  
}

output "public_subnet_id" {
    value = aws_subnet.public[*].id
  
}

output "privte_subnet_id" {
    value = aws_subnet.Backend[*].id
  
}

output "db_subnet_id" {
    value = aws_subnet.db[*].id
  
}
