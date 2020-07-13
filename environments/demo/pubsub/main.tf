resource "aws_kms_key" "monitor_sns_kms_key" {
}

module "monitoring_topic" {
  source = "git@github.com:abhishekamralkar/terraform-aws.git//modules/pubsub/"

  name              = "infra-notification"
  display_name      = var.name
  kms_master_key_id = aws_kms_key.monitor_sns_kms_key.arn
  tags = {
    Name           = format("%s-%s-%s", var.name, var.environment, "monitoringSNS")
    terraform      = "true"
    environment    = var.environment
    cloud_provider = var.cloud_provider
  }
}
