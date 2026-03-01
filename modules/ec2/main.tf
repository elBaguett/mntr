resource "aws_instance" "this" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.vpc_security_group_ids
  private_ip             = var.private_ip
  iam_instance_profile   = var.iam_instance_profile
  user_data              = var.user_data
  root_block_device {
    volume_type = "gp3"      
    volume_size = 40        
    delete_on_termination = true
    encrypted = true
  
    iops       = 3000        
    throughput = 125         
  }

  instance_market_options {
    spot_options {
      max_price = null
    }
    market_type = var.is_spot ? "spot" : null
  }

  tags = {
    Name = var.name
    Role = var.role
  }
}

resource "aws_ebs_volume" "cluster_data" {
  availability_zone = aws_instance.this.availability_zone
  size              = 40               
  type              = "gp3"
  encrypted         = true
  iops              = 3000
  throughput        = 125
  tags = {
    Name = "${var.name}-cluster-data"
  }
}

resource "aws_volume_attachment" "cluster_data" {
  device_name = "/dev/xvdf"           
  volume_id   = aws_ebs_volume.cluster_data.id
  instance_id = aws_instance.this.id
  skip_destroy = false                 
}