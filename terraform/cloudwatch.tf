resource "aws_cloudwatch_log_group" "log" {
  for_each = var.deployments

  name = "${var.name}-${each.key}"
  tags = var.tags
}