output "private_ip" { 
  value = aws_instance.this.private_ip 
}

output "id" {
  value = aws_instance.this.id
}
