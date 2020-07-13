data "terraform_remote_state" "sns" {
  backend = "s3"

  config = {
    bucket   = "demo-tf-state"
    key      = "demo/pub-sub/sns.tfstate"
    region   = "ap-south-1"
    role_arn = "arn:aws:iam::123456789012:role/tf-stage"
    profile  = "demo"
  }
}
