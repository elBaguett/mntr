resource "aws_security_group" "k8s" {
  name        = "k8s-global-sg"
  description = "Security Group for all kube nodes - SSH, TCP, UDP, BGP"
  vpc_id      = var.vpc_id
  
  ingress {
    description = "Allow all ping"
    from_port         = -1
    to_port           = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  ingress {
    description = "Allow all TCP"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  ingress {
    description = "Allow all UDP"
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "4"
    cidr_blocks = ["10.10.0.0/16", "10.20.0.0/16"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "4"
    cidr_blocks = ["10.10.0.0/16", "10.20.0.0/16"]
  }
#  ingress {
#    description = "BGP for Calico"
#    from_port   = 179
#    to_port     = 179
#    protocol    = "tcp"
#    cidr_blocks = ["0.0.0.0/0"] 
#  }
#  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k8s-global-sg"
  }
}