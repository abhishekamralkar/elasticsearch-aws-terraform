data "aws_iam_policy_document" "elastic_iam_pol" {
  statement {
    sid = ""

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    effect = "Allow"
  }
}

data "aws_ami" "elastic_ami" {
  most_recent = true


  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }


  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  owners = ["amazon"]
}

resource "aws_iam_instance_profile" "elastic_iam_ip" {
  count = 1
  name  = format("%s-%s-%s", "elastic", var.environment, "IAM-Instance-Profile")
  role  = join("", aws_iam_role.elastic_iam_role.*.name)
}

resource "aws_iam_role" "elastic_iam_role" {
  count              = 1
  name               = format("%s-%s-%s", "elastic", var.environment, "IAM-Role")
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.elastic_iam_pol.json
}

module "elastic_sg" {
  source = "git@github.com:abhishekamralkar/terraform-aws.git//modules/security_groups/"

  name                = format("%s-%s-%s", "elastic", var.environment, "SG")
  environment         = var.environment
  description         = "Security group for elastic server"
  vpc_id              = data.terraform_remote_state.vpc.outputs.vpc_id
  use_name_prefix     = false
  ingress_cidr_blocks = ["20.10.0.0/16"]
  ingress_rules       = ["elastic-rest-tcp", "elastic-java-tcp"]
  egress_rules        = ["all-all"]
  ingress_with_self = [
    {
      rule = "all-all"
    }
  ]

  tags = {
    terraform      = "true"
    environment    = var.environment
    cloud_provider = var.cloud_provider
  }
}


resource "aws_placement_group" "elastic_pg" {
  name     = format("%s-%s-%s", "elastic", var.environment, "PlacementGrp")
  strategy = "cluster"
}

resource "aws_kms_key" "elastic_kms_key" {
}

resource "aws_network_interface" "elastic_interface" {
  count = 1

  subnet_id = tolist(data.terraform_remote_state.vpc.outputs.public_subnets)[count.index]
}

module "elastic_ec2" {
  source = "git@github.com:abhishekamralkar/terraform-aws.git//modules/compute/"

  instance_count              = var.instances_number
  namespace                   = var.namespace
  name                        = var.namespace
  ami                         = data.aws_ami.elastic_ami.id
  instance_type               = "t2.micro"
  ebs_optimized               = false
  disable_api_termination     = false
  subnet_id                   = tolist(data.terraform_remote_state.vpc.outputs.public_subnets)[0]
  vpc_security_group_ids      = [module.elastic_sg.this_security_group_id]
  associate_public_ip_address = true
  # placement_group             = aws_placement_group.elastic_pg.id
  iam_instance_profile = join("", aws_iam_instance_profile.elastic_iam_ip.*.name)
  user_data            = "${file("userdata.sh")}"

  key_name   = data.terraform_remote_state.kp.outputs.demmo_key_pair_key_name
  monitoring = true
  root_block_device = [
    {
      volume_type = "gp2"
      volume_size = 10
    },
  ]

  ebs_block_device = [
    {
      device_name = "/dev/sdf"
      volume_type = "gp2"
      volume_size = 5
      encrypted   = true
      kms_key_id  = aws_kms_key.elastic_kms_key.arn
    }
  ]

  tags = {
    terraform      = "true"
    environment    = var.environment
    cloud_provider = var.cloud_provider
  }

}

module "elastic_status_alarms" {
  source = "git@github.com:abhishekamralkar/terraform-aws.git//modules/cloudwatch/"

  alarm_name          = var.name
  alarm_description   = "CPU is high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = 10
  period              = 60
  unit                = "Milliseconds"
  namespace           = "AWS/Ec2"
  metric_name         = "CPUUtilization"
  statistic           = "Average"

  dimensions = {
    environment = "Stage"
  }

  alarm_actions = [data.terraform_remote_state.sns.outputs.monitoring_topic_arn]
}
