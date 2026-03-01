variable "subnets_id" {
  type        = list(string)
}

variable "vpc_security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "vpc_id" {
  type        = string
}

variable "certificate_arn" {
  type        = string
}