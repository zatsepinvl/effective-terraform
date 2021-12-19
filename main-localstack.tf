provider "aws" {
  access_key                  = "test"
  secret_key                  = "test"
  region                      = "us-east-1"
  s3_force_path_style         = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    s3         = "http://localhost:4566"
    cloudfront = "http://localhost:4566"
    route53    = "http://localhost:4566"
  }
}


module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "effective-webapp"
  acl    = "public-read"

  website = {
    index_document = "index.html"
  }
}

// (!) AWS CloudFont is not supported by localstack community :(((.
module "cdn" {
  source = "terraform-aws-modules/cloudfront/aws"


  comment = "Effective Website CDN"

  origin = {
    effective_webapp = {
      domain_name = module.s3_bucket.s3_bucket_bucket_domain_name
    }
  }

  default_cache_behavior = {
    target_origin_id       = "effective_webapp"
    viewer_protocol_policy = "allow-all"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true
    query_string    = true
  }
  default_root_object    = "index.html"

  viewer_certificate = {
    cloudfront_default_certificate = true
  }
}
