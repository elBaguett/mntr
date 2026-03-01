output "vpc_id"             { value = aws_vpc.this.id }
output "cidr_block"         { value = aws_vpc.this.cidr_block }
output "master_subnet_id"   { value = aws_subnet.master_subnet.id }
output "worker_subnet_id"   { value = aws_subnet.worker_subnet.id }
output "route_table_id"     { value = aws_route_table.this.id }