######################
# VPC Endpoint for S3
######################
data "aws_vpc_endpoint_service" "s3" {
  count = var.create_vpc && var.enable_s3_endpoint ? 1 : 0

  service = "s3"
}

resource "aws_vpc_endpoint" "s3" {
  count = var.create_vpc && var.enable_s3_endpoint ? 1 : 0

  vpc_id       = local.vpc_id
  service_name = data.aws_vpc_endpoint_service.s3[0].service_name
  tags         = local.vpce_tags
}

resource "aws_vpc_endpoint_route_table_association" "private_s3" {
  count = var.create_vpc && var.enable_s3_endpoint ? local.nat_gateway_count : 0

  vpc_endpoint_id = aws_vpc_endpoint.s3[0].id
  route_table_id  = element(aws_route_table.private.*.id, count.index)
}


resource "aws_vpc_endpoint_route_table_association" "public_s3" {
  count = var.create_vpc && var.enable_s3_endpoint && length(var.public_subnets) > 0 ? 1 : 0

  vpc_endpoint_id = aws_vpc_endpoint.s3[0].id
  route_table_id  = aws_route_table.public[0].id
}

#######################
# VPC Endpoint for EC2
#######################
data "aws_vpc_endpoint_service" "ec2" {
  count = var.create_vpc && var.enable_ec2_endpoint ? 1 : 0

  service = "ec2"
}

resource "aws_vpc_endpoint" "ec2" {
  count = var.create_vpc && var.enable_ec2_endpoint ? 1 : 0

  vpc_id            = local.vpc_id
  service_name      = data.aws_vpc_endpoint_service.ec2[0].service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = var.ec2_endpoint_security_group_ids
  subnet_ids          = coalescelist(var.ec2_endpoint_subnet_ids, aws_subnet.private.*.id)
  private_dns_enabled = var.ec2_endpoint_private_dns_enabled
  tags                = local.vpce_tags
}

#######################
# VPC Endpoint for CloudWatch Monitoring
#######################
data "aws_vpc_endpoint_service" "monitoring" {
  count = var.create_vpc && var.enable_monitoring_endpoint ? 1 : 0

  service = "monitoring"
}

resource "aws_vpc_endpoint" "monitoring" {
  count = var.create_vpc && var.enable_monitoring_endpoint ? 1 : 0

  vpc_id            = local.vpc_id
  service_name      = data.aws_vpc_endpoint_service.monitoring[0].service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = var.monitoring_endpoint_security_group_ids
  subnet_ids          = coalescelist(var.monitoring_endpoint_subnet_ids, aws_subnet.private.*.id)
  private_dns_enabled = var.monitoring_endpoint_private_dns_enabled
  tags                = local.vpce_tags
}


#######################
# VPC Endpoint for CloudWatch Logs
#######################
data "aws_vpc_endpoint_service" "logs" {
  count = var.create_vpc && var.enable_logs_endpoint ? 1 : 0

  service = "logs"
}

resource "aws_vpc_endpoint" "logs" {
  count = var.create_vpc && var.enable_logs_endpoint ? 1 : 0

  vpc_id            = local.vpc_id
  service_name      = data.aws_vpc_endpoint_service.logs[0].service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = var.logs_endpoint_security_group_ids
  subnet_ids          = coalescelist(var.logs_endpoint_subnet_ids, aws_subnet.private.*.id)
  private_dns_enabled = var.logs_endpoint_private_dns_enabled
  tags                = local.vpce_tags
}


#######################
# VPC Endpoint for CloudWatch Events
#######################
data "aws_vpc_endpoint_service" "events" {
  count = var.create_vpc && var.enable_events_endpoint ? 1 : 0

  service = "events"
}

resource "aws_vpc_endpoint" "events" {
  count = var.create_vpc && var.enable_events_endpoint ? 1 : 0

  vpc_id            = local.vpc_id
  service_name      = data.aws_vpc_endpoint_service.events[0].service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = var.events_endpoint_security_group_ids
  subnet_ids          = coalescelist(var.events_endpoint_subnet_ids, aws_subnet.private.*.id)
  private_dns_enabled = var.events_endpoint_private_dns_enabled
  tags                = local.vpce_tags
}
