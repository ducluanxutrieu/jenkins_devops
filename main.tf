provider "aws" {
  region = "ap-southeast-1"
  default_tags {
    tags = {
      Environment = "Test"
      Name        = "Provider Tag"
    }
  }
}

terraform {
  backend "s3" {
    bucket = "ducluanxutrieu"
    key    = "terraform/jenkins"
    region = "ap-southeast-1"
  }
}