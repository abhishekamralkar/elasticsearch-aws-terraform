output "generic_security_group_id" {
  description = "The ID of the security group"
  value = concat(
    aws_security_group.generic.*.id,
    aws_security_group.generic_name_prefix.*.id,
    [""],
  )[0]
}

output "generic_security_group_vpc_id" {
  description = "The VPC ID"
  value = concat(
    aws_security_group.generic.*.vpc_id,
    aws_security_group.generic_name_prefix.*.vpc_id,
    [""],
  )[0]
}

output "generic_security_group_owner_id" {
  description = "The owner ID"
  value = concat(
    aws_security_group.generic.*.owner_id,
    aws_security_group.generic_name_prefix.*.owner_id,
    [""],
  )[0]
}

output "generic_security_group_name" {
  description = "The name of the security group"
  value = concat(
    aws_security_group.generic.*.name,
    aws_security_group.generic_name_prefix.*.name,
    [""],
  )[0]
}

output "generic_security_group_description" {
  description = "The description of the security group"
  value = concat(
    aws_security_group.generic.*.description,
    aws_security_group.generic_name_prefix.*.description,
    [""],
  )[0]
}
