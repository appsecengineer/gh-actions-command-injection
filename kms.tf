# Creates/manages KMS CMK
resource "aws_kms_key" "my-kms-key" {
  description = "Key is for client side encryption"
  #   customer_master_key_spec = var.key_spec
  is_enabled          = true
  enable_key_rotation = false
  tags = {
    Name = format("cloudlingists-%s", random_string.random_name.result)
  }
  policy = <<EOF
  
  {
    "Version": "2012-10-17",
    "Id": "key-default-1",
    "Statement": [
        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Action": "kms:*",
            "Resource": "*"
        }
    ]
}
EOF

  deletion_window_in_days = 7
}

# Add an alias to the key
resource "aws_kms_alias" "smc-kms-alias" {
  target_key_id = aws_kms_key.my-kms-key.key_id
  name          = format("alias/cloudlingists-%s", random_string.random_name.result)

}
