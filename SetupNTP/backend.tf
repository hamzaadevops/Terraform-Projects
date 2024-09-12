terraform {
  backend "s3" {
    bucket = "terraform-123321" # Replace with your S3 bucket name
    key    = "state.tfstate"
    region = "ap-south-1" # Replace with your region
  }
}

