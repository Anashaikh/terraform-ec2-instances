locals {
  s3_bucket_configs = [
    for env in var.environments : {
      s3_bucket_name = "my-s3-bucket-${env}"
      s3_policy_name = "s3-policy-${env}"
      s3_policy_arn  = "arn:aws:s3:::my-s3-bucket-${env}/*"
    }
  ]
}

# Create AWS Bucket in the AWS US region
resource "aws_s3_bucket" "web_buckets" {
  for_each = { for config in local.s3_bucket_configs : config.s3_bucket_name => config }
  bucket   = "${each.value.s3_bucket_name}-${timestamp()}"
  provider = aws.us

  tags = {
    Name = "S3-Bucket"
  }
}

# Allow EC2 Instances to Read/Write within S3 Bucket
resource "aws_s3_bucket_policy" "web_buckets" {
  for_each = aws_s3_bucket.web_buckets

  bucket = each.value.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": [
        "${each.value.arn}/*"
      ]
    }
  ]
}
POLICY
}

# Set S3 Bucket to be private
resource "aws_s3_bucket_acl" "example" {
  for_each = aws_s3_bucket.web_buckets
  bucket   = each.value.id
  acl      = "private"
}
