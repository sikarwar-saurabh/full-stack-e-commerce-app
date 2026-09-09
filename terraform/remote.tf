terraform {
  backend "s3" {
    bucket = "e-commerce-app-terraform-state-07-09-2026"
    key = "e-commerce-app/terraform.tfstate"
    region = "ap-south-1"
    use_lockfile = true
    encrypt = true
  }
}
