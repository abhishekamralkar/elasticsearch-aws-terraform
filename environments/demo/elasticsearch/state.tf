terraform {
  backend "s3" {
    bucket   = "demo-tf-state"
    key      = "demo/compute/elastic/elastic.tfstate"
    region   = "ap-south-1"
    encrypt  = true
    role_arn = "arn:aws:iam::123456789012:role/tf-stage"
    profile  = "demo"
  }
}
