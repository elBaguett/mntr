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
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH"
  }
# test deployment 
  ingress {
    description = "Allow ALL inbound traffic (IPv4)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.10.0.0/16", "10.20.0.0/16"]
    description = "All TCP between k8s nodes"
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "4"
    cidr_blocks = [
      "10.10.0.0/16",
      "10.20.0.0/16"
    ]
    description = "Calico IP-in-IP networking"
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = ["10.10.0.0/16", "10.20.0.0/16"]
    description = "All UDP between k8s nodes"
  }

  ingress {
    description = "Frontend HTTP (ALB)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ArgoCD UI"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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