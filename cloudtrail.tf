data "aws_caller_identity" "current" {
  # no arguments
}

resource "random_string" "random_name" {
  length  = 10
  special = false
  upper   = false
}


resource "aws_cloudtrail" "foobar" {
  depends_on = [
    aws_s3_bucket.foo, aws_instance.wb
  ]
  name                          = "cloudlingists-${random_string.random_name.result}-trail"
  s3_bucket_name                = aws_s3_bucket.foo.id
  s3_key_prefix                 = "prefix"
  include_global_service_events = false
  enable_log_file_validation    = false
}


resource "aws_s3_bucket" "foo" {
  bucket        = "vulnerable-${random_string.random_name.result}"
  force_destroy = true

}

resource "aws_s3_bucket_ownership_controls" "private_bucket" {
  bucket = aws_s3_bucket.foo.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_policy" "foo" {
  bucket = aws_s3_bucket.foo.id
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::vulnerable-${random_string.random_name.result}"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            
            "Resource": "arn:aws:s3:::vulnerable-${random_string.random_name.result}/prefix/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}
POLICY
}

resource "aws_s3_bucket_acl" "foo" {
  bucket = aws_s3_bucket.foo.id
  acl    = "public-read"
  depends_on = [aws_s3_bucket.foo,aws_s3_bucket_ownership_controls.foo]

}