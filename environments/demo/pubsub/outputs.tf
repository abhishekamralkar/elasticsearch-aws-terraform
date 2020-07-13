output "monitoring_topic_arn" {
  description = "The ARN of the SNS topic"
  value       = module.monitoring_topic.generic_sns_topic_arn
}

