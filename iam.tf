resource "aws_iam_access_key" "sagemaker" {
  user = aws_iam_user.user.name
}

resource "aws_iam_user" "user" {
  name = format("misconfig-iam-users-%s", random_string.random_name.result)
  path = "/"
}

data "aws_iam_policy" "s3_policy" {
  arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_policy_attachment" "attach-policy" {
  name       = "s3-policy-attachment"
  users      = [aws_iam_user.user.name]
  policy_arn = data.aws_iam_policy.s3_policy.arn
}

resource "aws_iam_role" "ssrf_role" {
  name               = "misconfig_role-${random_string.random_name.result}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "ssrf_policy" {
  name   = "misconfig_policy"
  role   = aws_iam_role.ssrf_role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}
