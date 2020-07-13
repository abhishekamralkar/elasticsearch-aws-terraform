data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket   = "demo-tf-state"
    key      = "demo/vpc/vpc.tfstate"
    region   = "ap-south-1"
    role_arn = "arn:aws:iam::123456789012:role/tf-stage"
    profile  = "demo"
  }
}
