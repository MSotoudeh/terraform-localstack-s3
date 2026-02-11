module "s3_static_site" {
  source = "../../modules/s3_bucket"

  bucket_name = "tf-localstack-lab-demo"
  acl         = "private"
  tags = {
    "environment" = "lab"
    "managed_by"  = "terraform"
  }
}
