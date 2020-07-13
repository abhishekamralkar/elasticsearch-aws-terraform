output "ids" {
  description = "List of IDs of instances"
  value       = module.elastic_ec2.id
}

output "public_dns" {
  description = "List of public DNS names assigned to the instances"
  value       = module.elastic_ec2.public_dns
}

output "vpc_security_group_ids" {
  description = "List of VPC security group ids assigned to the instances"
  value       = module.elastic_ec2.vpc_security_group_ids
}

output "root_block_device_volume_ids" {
  description = "List of volume IDs of root block devices of instances"
  value       = module.elastic_ec2.root_block_device_volume_ids
}

output "ebs_block_device_volume_ids" {
  description = "List of volume IDs of EBS block devices of instances"
  value       = module.elastic_ec2.ebs_block_device_volume_ids
}

output "tags" {
  description = "List of tags"
  value       = module.elastic_ec2.tags
}

output "placement_group" {
  description = "List of placement group"
  value       = module.elastic_ec2.placement_group
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = module.elastic_ec2.id[0]
}


output "instance_public_dns" {
  description = "Public DNS name assigned to the EC2 instance"
  value       = module.elastic_ec2.public_dns[0]
}


