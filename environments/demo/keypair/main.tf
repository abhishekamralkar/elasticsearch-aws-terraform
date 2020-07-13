resource "random_pet" "demo" {
  length = 2
}

module "demo_key_pair" {
  source = "git@github.com:abhishekamralkar/terraform-aws.git//modules/keypair/"

  key_name   = random_pet.demo.id
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDWBath4HBfo1NKM5OsnGIRGGtq12L6YepFtmZw6JU6I1bTYjeqljnmfxjssmnb9EBp98ST/271RNECkymriG8dJCrLNEGOQ4nlc3w6+iEVeucyr2/d1ujpgz5GpqgRoBriE0xUlaNOlmw270kVxchpFt+m/kw1HtQEERzQZhjxxF5CKNaco66FN8/jJA7Qx9bxeyBSrGYv88gvTfyrahrasyUGv8OIXWiPU1X2oowm7Pw9g0uL/l/c9HK5lzn2qjz1i80UZICmHxGno/BECnzmGpv7F+4XBH0K0UjFGMDyrjvm8MNyIBGKW94XiXv5E04bYRJh6lHPIce+lbH1oB+N aaa@aaa-debian-server"

}
