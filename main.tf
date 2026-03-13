terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
}

locals {
  all_public_keys = [
    file("~/.ssh/id_ed25519.pub")
  ]
}

provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "us-east"
  region = "us-east-1"
}

provider "aws" {
  alias  = "eu-west"
  region = "eu-west-1"
}

resource "aws_key_pair" "us_east" {
  region     = "us-east-1"
  key_name   = "aws-new"
  public_key = file("~/.ssh/id_ed25519.pub")
}

resource "aws_key_pair" "eu_west" {
  region     = "eu-west-1"
  key_name   = "aws-new"
  public_key = file("~/.ssh/id_ed25519.pub")
}

output "keypair_us_east" {
  value = aws_key_pair.us_east.key_name
}

output "keypair_eu_west" {
  value = aws_key_pair.eu_west.key_name
}

resource "aws_vpc_peering_connection" "peer" {
  depends_on = [
    module.vpc_us_east
  ]
  provider    = aws.us-east
  peer_vpc_id = module.vpc_eu_west.vpc_id
  vpc_id      = module.vpc_us_east.vpc_id
  peer_region = "eu-west-1"
  auto_accept = false
  tags = {
    Name = "us-east-eu-west-peer"
  }
}

resource "aws_vpc_peering_connection_accepter" "peer_accepter" {
  depends_on = [
    module.vpc_eu_west
  ]
  provider                  = aws.eu-west
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  auto_accept               = true
}

resource "aws_route" "us_east_to_eu_west" {
  depends_on = [
    module.vpc_us_east,
    module.vpc_eu_west
  ]
  provider                  = aws.us-east
  route_table_id            = module.vpc_us_east.route_table_id
  destination_cidr_block    = module.vpc_eu_west.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

resource "aws_route" "eu_west_to_us_east" {
  depends_on = [
    module.vpc_us_east,
    module.vpc_eu_west
  ]
  provider                  = aws.eu-west
  route_table_id            = module.vpc_eu_west.route_table_id
  destination_cidr_block    = module.vpc_us_east.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

module "iam" {
  source = "./modules/iam"
}

module "logs_us_east" {
  source     = "./modules/logs"
  providers  = { aws = aws.us-east }
  log_groups = [
    "/k8s/nodes",
    "/k8s/pods"
  ]
}

module "logs_eu_west" {
  source     = "./modules/logs"
  providers  = { aws = aws.eu-west }
  log_groups = [
    "/k8s/app/frontend",
    "/k8s/app/backend",
    "/k8s/app/db",
    "/k8s/app/errors"
  ]
}

#### VPC modules ####
module "vpc_us_east" {
  source     = "./modules/vpc"
  providers  = { aws = aws.us-east }
  az1        = "us-east-1a"
  az2        = "us-east-1b"
  cidr_block = "10.10.0.0/16"
  name       = "us-east-1-vpc"
}

module "vpc_eu_west" {
  source     = "./modules/vpc"
  providers  = { aws = aws.eu-west }
  az1        = "eu-west-1a"
  az2        = "eu-west-1b"
  cidr_block = "10.20.0.0/16"
  name       = "eu-west-1-vpc"
}

#### Security group example ####
module "security_group_us_east" {
  depends_on = [
    module.vpc_us_east
  ]
  providers     = { aws = aws.us-east }
  source        = "./modules/security_group"
  vpc_id        = module.vpc_us_east.vpc_id
  vpc_cidr      = "10.10.0.0/16"
  peer_vpc_cidr = "10.20.0.0/16"
}

module "security_group_eu_west" {
  depends_on = [
    module.vpc_eu_west
  ]
  providers     = { aws = aws.eu-west }
  source        = "./modules/security_group"
  vpc_id        = module.vpc_eu_west.vpc_id
  vpc_cidr      = "10.20.0.0/16"
  peer_vpc_cidr = "10.10.0.0/16"
}

#### Bastion ####
module "bastion" {
  depends_on = [
    module.vpc_us_east,
    module.security_group_us_east,
    module.iam,
    aws_key_pair.us_east
  ]
  source                 = "./modules/ec2"
  ami                    = "ami-0030e4319cbf4dbf2"
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.us_east.key_name
  subnet_id              = module.vpc_us_east.master_subnet_id
  iam_instance_profile   = module.iam.aws_iam_instance_profile
  vpc_security_group_ids = [module.security_group_us_east.security_group_id]
  private_ip             = "10.10.10.10"
  name                   = "bastion"
  role                   = "bastion"
  is_spot                = false
  all_public_keys        = local.all_public_keys
  user                   = "ubuntu"
  user_data              = file("./scripts/disk-fix.sh")
  providers              = { aws = aws.us-east }
}

resource "aws_eip" "bastion" {
  instance   = module.bastion.id
  depends_on = [module.bastion]
}

#### Masters ####

module "master_us_east" {
  depends_on = [
    module.vpc_us_east,
    module.security_group_us_east,
    module.iam,
    aws_key_pair.us_east
  ]
  source                 = "./modules/ec2"
  ami                    = "ami-0030e4319cbf4dbf2"
  instance_type          = "t3.large"
  key_name               = aws_key_pair.us_east.key_name
  subnet_id              = module.vpc_us_east.master_subnet_id
  iam_instance_profile   = module.iam.aws_iam_instance_profile
  vpc_security_group_ids = [module.security_group_us_east.security_group_id]
  private_ip             = "10.10.10.11"
  name                   = "2011k8s-aws-new"
  role                   = "master"
  is_spot                = false
  all_public_keys        = local.all_public_keys
  user                   = "ubuntu"
  user_data              = file("./scripts/disk-fix.sh")
  providers              = { aws = aws.us-east }
}

module "master_eu_west" {
  depends_on = [
    module.vpc_eu_west,
    module.security_group_eu_west,
    module.iam,
    aws_key_pair.eu_west
  ]
  source                 = "./modules/ec2"
  ami                    = "ami-0f27749973e2399b6"
  instance_type          = "t3.large"
  key_name               = aws_key_pair.eu_west.key_name
  subnet_id              = module.vpc_eu_west.master_subnet_id
  iam_instance_profile   = module.iam.aws_iam_instance_profile
  vpc_security_group_ids = [module.security_group_eu_west.security_group_id]
  private_ip             = "10.20.10.10"
  name                   = "2010k8s-master2"
  role                   = "master"
  is_spot                = false
  all_public_keys        = local.all_public_keys
  user                   = "ubuntu"
  user_data              = file("./scripts/disk-fix.sh")
  providers              = { aws = aws.eu-west }
}

#### Workers - Stateless ####

module "stateless_worker1" {
  depends_on = [
    module.master_us_east,
    module.iam,
    aws_key_pair.us_east
  ]
  source                 = "./modules/ec2"
  ami                    = "ami-0030e4319cbf4dbf2"
  instance_type          = "t3.large"
  key_name               = aws_key_pair.us_east.key_name
  subnet_id              = module.vpc_us_east.worker_subnet_id
  iam_instance_profile   = module.iam.aws_iam_instance_profile
  vpc_security_group_ids = [module.security_group_us_east.security_group_id]
  private_ip             = "10.10.20.14"
  name                   = "114stateless-worker1"
  role                   = "stateless_worker"
  is_spot                = false
  all_public_keys        = local.all_public_keys
  user                   = "ubuntu"
  user_data              = file("./scripts/disk-fix.sh")
  providers              = { aws = aws.us-east }
}

module "stateless_worker2" {
  depends_on = [
    module.master_eu_west,
    module.iam,
    aws_key_pair.eu_west
  ]
  source                 = "./modules/ec2"
  ami                    = "ami-0f27749973e2399b6"
  instance_type          = "t3.large"
  key_name               = aws_key_pair.eu_west.key_name
  subnet_id              = module.vpc_eu_west.worker_subnet_id
  iam_instance_profile   = module.iam.aws_iam_instance_profile
  vpc_security_group_ids = [module.security_group_eu_west.security_group_id]
  private_ip             = "10.20.20.12"
  name                   = "112stateless-worker2"
  role                   = "stateless_worker"
  is_spot                = false
  all_public_keys        = local.all_public_keys
  user                   = "ubuntu"
  user_data              = file("./scripts/disk-fix.sh")
  providers              = { aws = aws.eu-west }
}

#### Workers - Stateful ####

module "stateful_worker1" {
  depends_on = [
    module.master_us_east,
    module.iam,
    aws_key_pair.us_east
  ]
  source                 = "./modules/ec2"
  ami                    = "ami-0030e4319cbf4dbf2"
  instance_type          = "t3.large"
  key_name               = aws_key_pair.us_east.key_name
  subnet_id              = module.vpc_us_east.worker_subnet_id
  iam_instance_profile   = module.iam.aws_iam_instance_profile
  vpc_security_group_ids = [module.security_group_us_east.security_group_id]
  private_ip             = "10.10.20.11"
  name                   = "111stateful-worker1"
  role                   = "stateful_worker"
  is_spot                = false
  all_public_keys        = local.all_public_keys
  user                   = "ubuntu"
  user_data              = file("./scripts/disk-fix.sh")
  providers              = { aws = aws.us-east }
}

module "stateful_worker2" {
  depends_on = [
    module.master_eu_west,
    module.iam,
    aws_key_pair.eu_west
  ]
  source                 = "./modules/ec2"
  ami                    = "ami-0f27749973e2399b6"
  instance_type          = "t3.large"
  key_name               = aws_key_pair.eu_west.key_name
  subnet_id              = module.vpc_eu_west.worker_subnet_id
  iam_instance_profile   = module.iam.aws_iam_instance_profile
  vpc_security_group_ids = [module.security_group_eu_west.security_group_id]
  private_ip             = "10.20.20.10"
  name                   = "110stateful-worker2"
  role                   = "stateful_worker"
  is_spot                = false
  all_public_keys        = local.all_public_keys
  user                   = "ubuntu"
  user_data              = file("./scripts/disk-fix.sh")
  providers              = { aws = aws.eu-west }
}
## Load balancer
module "load_balancer_eu_west" {
  depends_on = [
    module.master_us_east,
    module.master_eu_west,
    module.stateless_worker1,
    module.stateless_worker2,
    module.stateful_worker1,
    module.stateful_worker2,
    null_resource.copy_key_to_bastion
  ]
  source                 = "./modules/lb"
  providers              = { aws = aws.eu-west }
  subnets_id             = [module.vpc_eu_west.worker_subnet_id, module.vpc_eu_west.master_subnet_id]
  vpc_id                 = module.vpc_eu_west.vpc_id
  vpc_security_group_ids = [module.security_group_eu_west.security_group_id]
  certificate_arn        = aws_acm_certificate.argocd_eu_west.arn
}

module "load_balancer_us_east" {
  depends_on = [
    module.master_us_east,
    module.master_eu_west,
    module.stateless_worker1,
    module.stateless_worker2,
    module.stateful_worker1,
    module.stateful_worker2,
    null_resource.copy_key_to_bastion
  ]
  source                 = "./modules/lb"
  providers              = { aws = aws.us-east }
  subnets_id             = [module.vpc_us_east.worker_subnet_id, module.vpc_us_east.master_subnet_id]
  vpc_id                 = module.vpc_us_east.vpc_id
  vpc_security_group_ids = [module.security_group_us_east.security_group_id]
  certificate_arn        = aws_acm_certificate.argocd_us_east.arn
}


resource "aws_lb_target_group_attachment" "us_east_argocd" {
  for_each = toset([
    module.master_us_east.private_ip,
    module.stateless_worker1.private_ip,
    module.stateful_worker1.private_ip
  ])
  target_group_arn = module.load_balancer_us_east.target_group_arn
  target_id        = each.key
  port             = 30282
  provider         = aws.us-east
  depends_on = [
    module.load_balancer_us_east
  ]
}

resource "aws_lb_target_group_attachment" "eu_west_argocd" {
  for_each = toset([
    module.master_eu_west.private_ip,
    module.stateless_worker2.private_ip,
    module.stateful_worker2.private_ip
  ])
  target_group_arn = module.load_balancer_eu_west.target_group_arn
  target_id        = each.key
  port             = 30282
  provider         = aws.eu-west
  depends_on = [
    module.load_balancer_eu_west
  ]
}

## Load balancer
output "all_private_ips" {
  value = [
    module.master_us_east.private_ip,
    module.master_eu_west.private_ip,
    module.stateless_worker1.private_ip,
    module.stateless_worker2.private_ip,
    module.stateful_worker1.private_ip,
    module.stateful_worker2.private_ip
  ]
}

output "bastion_public_ip" {
  value = aws_eip.bastion.public_ip
}

output "bastion_private_ip" {
  value = module.bastion.private_ip
}

output "masters" {
  value = [
    module.master_us_east.private_ip,
    module.master_eu_west.private_ip
  ]
}

output "workers" {
  value = [
    module.stateless_worker1.private_ip,
    module.stateless_worker2.private_ip,
    module.stateful_worker1.private_ip,
    module.stateful_worker2.private_ip
  ]
}

resource "local_file" "ansible_inventory" {
  depends_on = [
    module.master_us_east,
    module.master_eu_west,
    module.stateless_worker1,
    module.stateless_worker2,
    module.stateful_worker1,
    module.stateful_worker2,
    null_resource.copy_key_to_bastion
  ]

  filename = "${path.module}/ansible_hosts.ini"
  content = templatefile("${path.module}/ansible_hosts.tmpl", {
    master_1                     = module.master_us_east.private_ip
    master_2                     = module.master_eu_west.private_ip
    worker_1                     = module.stateless_worker1.private_ip
    worker_2                     = module.stateless_worker2.private_ip
    worker_3                     = module.stateful_worker1.private_ip
    worker_4                     = module.stateful_worker2.private_ip
    bastion_public_ip            = aws_eip.bastion.public_ip
    ansible_user                 = "ubuntu"
    ansible_ssh_private_key_file = "~/.ssh/id_ed25519"
  })
}

resource "null_resource" "copy_key_to_bastion" {
  depends_on = [aws_eip.bastion, module.bastion]

  provisioner "local-exec" {
    command = "sleep 60 && for i in {1..12}; do ssh -o StrictHostKeyChecking=no -i ~/.ssh/id_ed25519 ubuntu@${aws_eip.bastion.public_ip} echo ok && break || sleep 5; done; scp -o StrictHostKeyChecking=no -i ~/.ssh/id_ed25519 ~/.ssh/id_ed25519 ubuntu@${aws_eip.bastion.public_ip}:/home/ubuntu/aws-new; ssh -o StrictHostKeyChecking=no -i ~/.ssh/id_ed25519 ubuntu@${aws_eip.bastion.public_ip} 'chmod 600 /home/ubuntu/aws-new'"
  }
}
# resources are not being copied, you wanted to automate calicoctl and allow_all policy
resource "null_resource" "copy_manifests" {
  depends_on = [null_resource.copy_key_to_bastion, module.master_eu_west]
  provisioner "local-exec" {
    command = "scp -i ~/.ssh/id_ed25519 -o \"StrictHostKeyChecking=no\" -o \"UserKnownHostsFile=/dev/null\" -o ProxyCommand=\"ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ~/.ssh/id_ed25519 -W %h:%p ubuntu@${aws_eip.bastion.public_ip}\" -r ./manifests ubuntu@10.20.10.10:/home/ubuntu/code"
  }
}

resource "null_resource" "ansible_apply" {
  depends_on = [local_file.ansible_inventory, null_resource.copy_manifests]
  provisioner "local-exec" {
    command = "sleep 30 && ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ./ansible_hosts.ini ./modules/k8s-bootstrap/bootstrap.yml --private-key=~/.ssh/id_ed25519 && sleep 30 && ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ./ansible_hosts.ini ./modules/k8s-bootstrap/post-bootstrap.yml --private-key=~/.ssh/id_ed25519"
  }
}

#resource "null_resource" "ansible_post_bootstrap" {
#  depends_on = [null_resource.ansible_apply, aws_route53_record.argocd_west, aws_route53_record.argocd_east]
#  provisioner "local-exec" {
#    command = "sleep 30 && ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ./ansible_hosts.ini ./modules/k8s-bootstrap/post-bootstrap.yml --private-key=~/.ssh/id_ed25519"
#  }
#}

#DNS#
data "aws_route53_zone" "main" {
  name = "argocd.click."
}

resource "aws_route53_record" "argocd_east" {
  depends_on = [module.load_balancer_us_east, null_resource.ansible_apply]
  zone_id    = data.aws_route53_zone.main.zone_id
  name       = "argocd"
  type       = "A"

  alias {
    name                   = module.load_balancer_us_east.dns_name
    zone_id                = module.load_balancer_us_east.zone_id
    evaluate_target_health = true
  }

  set_identifier = "us-east-1"
  latency_routing_policy {
    region = "us-east-1"
  }
}

resource "aws_route53_record" "argocd_west" {
  depends_on = [module.load_balancer_eu_west,
  null_resource.ansible_apply, ]
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "argocd"
  type    = "A"

  alias {
    name                   = module.load_balancer_eu_west.dns_name
    zone_id                = module.load_balancer_eu_west.zone_id
    evaluate_target_health = true
  }

  set_identifier = "eu-west-1"
  latency_routing_policy {
    region = "eu-west-1"
  }
}

resource "aws_acm_certificate" "argocd_us_east" {
  provider          = aws.us-east
  domain_name       = "argocd.click"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate" "argocd_eu_west" {
  provider          = aws.eu-west
  domain_name       = "argocd.click"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "argocd_us_east_validation" {
  provider = aws.us-east
  for_each = {
    for dvo in aws_acm_certificate.argocd_us_east.domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }
  zone_id = data.aws_route53_zone.main.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 300
}


resource "aws_acm_certificate_validation" "argocd_us_east" {
  provider                = aws.us-east
  certificate_arn         = aws_acm_certificate.argocd_us_east.arn
  validation_record_fqdns = [for record in aws_route53_record.argocd_us_east_validation : record.fqdn]
}

#DNS#