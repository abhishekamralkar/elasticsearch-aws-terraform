data "aws_security_group" "default" {
  name   = "default"
  vpc_id = module.vpc.vpc_id
}

module "vpc" {
  source = "git@github.com:abhishekamralkar/terraform-aws.git//modules/networking/"

  name        = var.name
  environment = var.environment
  cidr        = "20.10.0.0/16"

  azs             = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
  azs-short       = ["1a", "1b", "1c"]
  private_subnets = ["20.10.1.0/24", "20.10.2.0/24", "20.10.3.0/24"]
  public_subnets  = ["20.10.11.0/24", "20.10.12.0/24", "20.10.13.0/24"]

  create_database_subnet_group = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_ipv6        = true

  enable_dhcp_options              = true
  dhcp_options_domain_name         = "ap-south-1.compute.internal"
  dhcp_options_domain_name_servers = ["AmazonProvidedDNS"]

  # VPC endpoint for S3
  enable_s3_endpoint = true

  # VPC Endpoint for EC2
  enable_ec2_endpoint              = true
  ec2_endpoint_private_dns_enabled = true
  ec2_endpoint_security_group_ids  = [data.aws_security_group.default.id]


  use_num_suffix = true
  tags = {
    terraform      = "true"
    environment    = var.environment
    cloud_provider = var.cloud_provider
  }

  vpc_endpoint_tags = {
    Project  = "demo"
    Endpoint = "true"
  }
}
