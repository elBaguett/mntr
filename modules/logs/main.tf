resource "aws_cloudwatch_log_group" "this" {
  for_each          = toset(var.log_groups)
  name              = each.value
  retention_in_days = 14
}