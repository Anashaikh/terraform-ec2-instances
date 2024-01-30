
# Create AWS Bucket in the AWS US region
resource "aws_s3_bucket" "web_buckets" {
  bucket   = "test-bucket01821212"
  provider = aws.us

  tags = {
    Name = "S3-Bucket"
  }
}


# Allow EC2 Instances to Read/Write within S3 Bucket

resource "aws_s3_bucket_policy" "web_buckets" {
  bucket = aws_s3_bucket.web_buckets.id

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
	"${aws_s3_bucket.web_buckets.arn}/*"
      ]
    }
  ]
}
POLICY
}

# Set S3 Bucket to be private
resource "aws_s3_bucket_acl" "example" {
  depends_on = [aws_s3_bucket.web_buckets]

  bucket = aws_s3_bucket.web_buckets.id
  acl    = "private"
}

