locals {
  max_subnet_length = max(
    length(var.private_subnets),
    length(var.database_subnets),
  )
  nat_gateway_count = var.single_nat_gateway ? 1 : var.one_nat_gateway_per_az ? length(var.azs) : local.max_subnet_length


  vpc_id = element(
    concat(
      aws_vpc_ipv4_cidr_block_association.generic.*.vpc_id,
      aws_vpc.generic.*.id,
      [""],
    ),
    0,
  )

  vpce_tags = merge(
    var.tags,
    var.vpc_endpoint_tags,
  )
}

#-----------------------------------------#
# this is the module for the VPC creation #
#-----------------------------------------#
resource "aws_vpc" "generic" {
  count = var.create_vpc ? 1 : 0

  cidr_block                       = var.cidr
  instance_tenancy                 = var.instance_tenancy
  enable_dns_hostnames             = var.enable_dns_hostnames
  enable_dns_support               = var.enable_dns_support
  assign_generated_ipv6_cidr_block = var.enable_ipv6

  tags = merge(
    {
      "Name" = format("%s-%s-%s", var.name, var.environment, "VPC")
    },
    var.tags
  )
}

#--------------------------------------------------------------#
# this is the module for the ipv4 block association            #
#--------------------------------------------------------------#
resource "aws_vpc_ipv4_cidr_block_association" "generic" {
  count = var.create_vpc && length(var.secondary_cidr_blocks) > 0 ? length(var.secondary_cidr_blocks) : 0

  vpc_id = aws_vpc.generic[0].id

  cidr_block = element(var.secondary_cidr_blocks, count.index)
}

#----------------------------------------#
# this is the module for the DHCP Options#
#----------------------------------------#
resource "aws_vpc_dhcp_options" "generic" {
  count               = var.create_vpc && var.enable_dhcp_options ? 1 : 0
  domain_name         = var.dhcp_options_domain_name
  domain_name_servers = var.dhcp_options_domain_name_servers


  tags = merge(
    {
      "Name" = format("%s-%s-%s", var.name, var.environment, "DHCP-Options")
    },
    var.tags,
    var.dhcp_options_tags,
  )
}

#--------------------------------------------------------------#
# this is the module for the dhcp associations                 #
#--------------------------------------------------------------#
resource "aws_vpc_dhcp_options_association" "generic" {
  count = var.create_vpc && var.enable_dhcp_options ? 1 : 0

  vpc_id          = local.vpc_id
  dhcp_options_id = aws_vpc_dhcp_options.generic[0].id
}

#-----------------------------------------------#
# this is the module for the internet gateway   #
#-----------------------------------------------#
resource "aws_internet_gateway" "generic" {
  count = var.create_vpc && length(var.public_subnets) > 0 ? 1 : 0

  vpc_id = local.vpc_id

  tags = merge(
    {
      "Name" = format("%s-%s-%s", var.name, var.environment, "IG")
    },
    var.tags,
    var.igw_tags,
  )
}


#----------------------------------------------#
# Public Routes                                #
#----------------------------------------------#
# this is the module for the public route table#
#----------------------------------------------#
resource "aws_route_table" "public" {
  count = var.create_vpc && length(var.public_subnets) > 0 ? 1 : 0

  vpc_id = local.vpc_id

  tags = merge(
    {
      "Name" = format("%s-%s-${var.public_rt_suffix}", var.name, var.environment)
    },
    var.tags,
    var.public_route_table_tags,
  )
}

#--------------------------------------------------#
# this is the module for the public IG  route table#
#--------------------------------------------------#
resource "aws_route" "public_internet_gateway" {
  count = var.create_vpc && length(var.public_subnets) > 0 ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.generic[0].id

  timeouts {
    create = "5m"
  }
}


#--------------------------------------------------------------#
# Private routes                                               #
#--------------------------------------------------------------#
# this is the module for the private route table               #
#--------------------------------------------------------------#
resource "aws_route_table" "private" {
  count = var.create_vpc && local.max_subnet_length > 0 ? local.nat_gateway_count : 0

  vpc_id = local.vpc_id

  tags = merge(
    {
      "Name" = var.single_nat_gateway ? "${var.name}-${var.environment}-${var.private_rt_suffix}" : format(
        "%s-%s-${var.private_subnet_suffix}-%s",
        var.name,
        var.environment,
        element(var.azs-short, count.index),
      )
    },
    var.tags,
    var.private_route_table_tags,
  )

  lifecycle {
    ignore_changes = [propagating_vgws]
  }
}


#--------------------------------------------------------------#
# this is the module for the public subnet                     #
#--------------------------------------------------------------#
resource "aws_subnet" "public" {
  count = var.create_vpc && length(var.public_subnets) > 0 && (false == var.one_nat_gateway_per_az || length(var.public_subnets) >= length(var.azs)) ? length(var.public_subnets) : 0

  vpc_id                          = local.vpc_id
  cidr_block                      = element(concat(var.public_subnets, [""]), count.index)
  availability_zone               = element(var.azs, count.index)
  map_public_ip_on_launch         = var.map_public_ip_on_launch
  assign_ipv6_address_on_creation = var.public_subnet_assign_ipv6_address_on_creation == null ? var.assign_ipv6_address_on_creation : var.public_subnet_assign_ipv6_address_on_creation

  ipv6_cidr_block = var.enable_ipv6 && length(var.public_subnet_ipv6_prefixes) > 0 ? cidrsubnet(aws_vpc.generic[0].ipv6_cidr_block, 8, var.public_subnet_ipv6_prefixes[count.index]) : null

  tags = merge(
    {
      "Name" = format(
        "%s-%s-${var.public_subnet_suffix}-%s",
        var.name,
        var.environment,
        element(var.azs-short, count.index),
      )
    },
    var.tags,
    var.public_subnet_tags,
  )
}

#--------------------------------------------------------------#
# this is the module for the private subnet                    #
#--------------------------------------------------------------#
resource "aws_subnet" "private" {
  count = var.create_vpc && length(var.private_subnets) > 0 ? length(var.private_subnets) : 0

  vpc_id                          = local.vpc_id
  cidr_block                      = var.private_subnets[count.index]
  availability_zone               = element(var.azs, count.index)
  assign_ipv6_address_on_creation = var.private_subnet_assign_ipv6_address_on_creation == null ? var.assign_ipv6_address_on_creation : var.private_subnet_assign_ipv6_address_on_creation

  ipv6_cidr_block = var.enable_ipv6 && length(var.private_subnet_ipv6_prefixes) > 0 ? cidrsubnet(aws_vpc.generic[0].ipv6_cidr_block, 8, var.private_subnet_ipv6_prefixes[count.index]) : null

  tags = merge(
    {
      "Name" = format(
        "%s-%s-${var.private_subnet_suffix}-%s",
        var.name,
        var.environment,
        element(var.azs-short, count.index),
      )
    },
    var.tags,
    var.private_subnet_tags,
  )
}

#---------------------------------------------------------------#
# this is the module for the nat gateway                        #
#---------------------------------------------------------------#
locals {
  nat_gateway_ips = split(
    ",",
    var.reuse_nat_ips ? join(",", var.external_nat_ip_ids) : join(",", aws_eip.nat.*.id),
  )
}

resource "aws_eip" "nat" {
  count = var.create_vpc && var.enable_nat_gateway && false == var.reuse_nat_ips ? local.nat_gateway_count : 0

  vpc = true

  tags = merge(
    {
      "Name" = format(
        "%s-%s-%s-%s",
        var.name,
        var.environment,
        "EIP",
        element(var.azs-short, var.single_nat_gateway ? 0 : count.index),
      )
    },
    var.tags,
    var.nat_eip_tags,
  )
}

resource "aws_nat_gateway" "generic" {
  count = var.create_vpc && var.enable_nat_gateway ? local.nat_gateway_count : 0

  allocation_id = element(
    local.nat_gateway_ips,
    var.single_nat_gateway ? 0 : count.index,
  )
  subnet_id = element(
    aws_subnet.public.*.id,
    var.single_nat_gateway ? 0 : count.index,
  )

  tags = merge(
    {
      "Name" = format(
        "%s-%s-%s-%s",
        var.name,
        var.environment,
        "NGW",
        element(var.azs-short, var.single_nat_gateway ? 0 : count.index),
      )
    },
    var.tags,
    var.nat_gateway_tags,
  )

  depends_on = [aws_internet_gateway.generic]
}


#---------------------------------------------------------------#
# this is the module for the private route table association    #
#---------------------------------------------------------------#
resource "aws_route_table_association" "private" {
  count = var.create_vpc && length(var.private_subnets) > 0 ? length(var.private_subnets) : 0

  subnet_id = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(
    aws_route_table.private.*.id,
    var.single_nat_gateway ? 0 : count.index,
  )
}

#---------------------------------------------------------------#
# this is the module for the public route table association     #
#---------------------------------------------------------------#
resource "aws_route_table_association" "public" {
  count = var.create_vpc && length(var.public_subnets) > 0 ? length(var.public_subnets) : 0

  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public[0].id
}


resource "aws_flow_log" "generic" {
  iam_role_arn    = aws_iam_role.generic.arn
  log_destination = aws_cloudwatch_log_group.generic.arn
  traffic_type    = "ALL"
  vpc_id          = element(concat(aws_vpc.generic.*.id, [""]), 0)
}

resource "aws_cloudwatch_log_group" "generic" {
  name = format("%s-%s-%s", var.name, var.environment, "FlowLogGrp")
}

resource "aws_iam_role" "generic" {
  name = format("%s-%s-%s", var.name, var.environment, "FlowLog-IAM")

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "generic" {
  name = format("%s-%s-%s", var.name, var.environment, "FlowLogIAMRolePol")
  role = aws_iam_role.generic.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

