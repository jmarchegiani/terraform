# Thumbnail Generator

Create thumbnails from Images and PDFs

## Configuration

First, you'll need to set your Access Key, Secret Key, Bucket name AND region values into the terraform file:

```terraform
provider "aws" {
  region     = var.region_name
  access_key = "ACCESS_KEY_ID"
  secret_key = "SECRET_ACCESS_KEY"
}

variable "bucket_app_name" {
  default = "BUCKET_NAME"
}

variable "region_name" {
  default = "xx-xxxx-x"
}
```

## Installation

The whole installation and setup of this application is entirely based on Terraform. By running the terraform apply, the creation of the following resources will begin:

- Lambda function (the core of the app, this will recieve events from S3 and create a thumbnail of the file uploaded)
- S3 notification (on the referenced bucket)
- IAM Role & Policy (to be used by the lambda function)
- CloudWatch log group (for lambda logs)

```bash
terraform init
terraform plan
terraform apply
```

## Usage

Upload a file without extension, the app will recognize the mimeType of the file.

In max. 3 seconds the app will generate the thumbnail of the file in the same bucket

## Author
[Juan Pablo Marchegiani](https://www.upwork.com/freelancers/~0165ae0cb53b811da9)