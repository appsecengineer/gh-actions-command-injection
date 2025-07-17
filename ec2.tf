resource "tls_private_key" "ase_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ssh" {
  depends_on = [
    tls_private_key.ase_ssh_key
  ]
  key_name   = format("ase_ssh_key-%s", random_string.random_name.result)
  public_key = tls_private_key.ase_ssh_key.public_key_openssh
}

resource "aws_iam_instance_profile" "ssrf_profile" {
  name       = "ssrf_profile-${random_string.random_name.result}"
  role       = aws_iam_role.ssrf_role.id
  depends_on = [aws_iam_role.ssrf_role]
}

data "aws_ami" "amz_linux" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn-ami-*-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  owners = ["amazon"]
}

resource "aws_instance" "wb" {
  depends_on           = [aws_iam_instance_profile.ssrf_profile]
  ami                  = data.aws_ami.amz_linux.id
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.ssrf_profile.name
  key_name             = aws_key_pair.ssh.key_name
  subnet_id            = aws_subnet.public-subnet.id

  vpc_security_group_ids      = [aws_security_group.logging-SG.id]
  associate_public_ip_address = true
  source_dest_check           = false
  user_data                   = file("script.sh")
  tags = {
    Name = "Web Application"
  }
}


