resource "aws_security_group" "k8s" {
  name        = "k8s-global-sg"
  description = "Security Group for all kube nodes - SSH, K8s, BGP, App"
  vpc_id      = var.vpc_id

  ingress {
    description = "ICMP ping"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.10.0.0/16", "10.20.0.0/16"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  ingress {
    description = "K8s API"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["10.10.0.0/16", "10.20.0.0/16"]
  }

  ingress {
    description = "etcd"
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = ["10.10.0.0/16", "10.20.0.0/16"]
  }

  ingress {
    description = "kubelet API"
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["10.10.0.0/16", "10.20.0.0/16"]
  }

  ingress {
    description = "Calico BGP"
    from_port   = 179
    to_port     = 179
    protocol    = "tcp"
    cidr_blocks = ["10.10.0.0/16", "10.20.0.0/16"]
  }

  ingress {
    description = "Frontend HTTP (ALB)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Backend (nginx → go app)"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["10.10.0.0/16", "10.20.0.0/16"]
  }

  ingress {
    description = "PostgreSQL Patroni"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.10.0.0/16", "10.20.0.0/16"]
  }

  ingress {
    description = "Patroni REST API"
    from_port   = 8008
    to_port     = 8008
    protocol    = "tcp"
    cidr_blocks = ["10.10.0.0/16", "10.20.0.0/16"]
  }

  ingress {
    description = "K8s nodePort"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["10.10.0.0/16", "10.20.0.0/16"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k8s-global-sg"
  }
}