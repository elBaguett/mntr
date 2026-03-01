variable "ami" {
  description = "AMI ID (use OS image for your region)"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_name" {
  description = "SSH key name"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID"
  type        = string
}

variable "vpc_security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "private_ip" {
  description = "Private IP address"
  type        = string
}

variable "name" {
  description = "Instance Name tag"
  type        = string
}

variable "role" {
  description = "Role (master/worker/router)"
  type        = string
}

variable "is_spot" {
  description = "Use spot instance?"
  type        = bool
  default     = false
}

variable "iam_instance_profile" {
  description = "IAM instance profile name"
  type        = string
  default     = null
}

variable "user" {
  description = "Username for SSH/local in user_data"
  type        = string
  default     = "ubuntu"
}

variable "all_public_keys" {
  description = "keys"
  type        = set(string)
}

variable "user_data" {
  description = "init script"
  type        = string
}