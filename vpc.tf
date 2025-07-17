resource "aws_vpc" "stack-example-vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "cloudlingists-vpc"
  }
}
