resource "aws_s3_bucket" "ssrf_bucket" {
  bucket        = format("%s-ssrf", random_string.random_name.result)
  force_destroy = true
}

resource "aws_s3_object" "uploadfiles" {
  bucket     = aws_s3_bucket.ssrf_bucket.id
  key        = "creditcardnumbers.txt"
  source     = "creditcardnumbers.txt"
  depends_on = [aws_s3_bucket.ssrf_bucket]
}


resource "aws_s3_bucket_acl" "ssrf" {
  bucket     = aws_s3_bucket.ssrf_bucket.id
  acl        = "private"
  depends_on = [aws_s3_bucket.ssrf_bucket,aws_s3_bucket_ownership_controls.ssrf_bucket]
}

resource "aws_s3_bucket_ownership_controls" "private_bucket" {
  bucket = aws_s3_bucket.ssrf_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_policy" "foo1" {
  bucket = aws_s3_bucket.ssrf_bucket.id
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Action": [
                "s3:*",
                "s3:ListBucket"
            ],
          "Resource": [
              "arn:aws:s3:::${random_string.random_name.result}-ssrf/*",
                "arn:aws:s3:::${random_string.random_name.result}-ssrf"
            ]
        }
    ]
}
POLICY
}