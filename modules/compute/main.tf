#-------------------------------------------------------------------------------
# Prerequisites
#-------------------------------------------------------------------------------

locals {
  id = "ptfe-${var.environment}-${random_string.id.result}"

  ssh_public_key_path  = "${path.root}"
  public_key_filename  = "${local.ssh_public_key_path}/${local.id}.pub"
  private_key_filename = "${local.ssh_public_key_path}/${local.id}.priv"
}

resource "tls_private_key" "default" {
  algorithm = "RSA"
}

resource "aws_key_pair" "generated" {
  key_name   = local.id
  public_key = tls_private_key.default.public_key_openssh
}

resource "local_file" "private_key_pem" {
  content  = tls_private_key.default.private_key_pem
  filename = local.private_key_filename
}

resource "null_resource" "chmod" {
  triggers = {
    key_data = local_file.private_key_pem.content
  }

  provisioner "local-exec" {
    command = "chmod 600 ${local.private_key_filename}"
  }
}

resource "random_string" "id" {
  length  = 5
  upper   = false
  number  = false
  special = false
}

resource "random_string" "initial_admin_user_password" {
  length = 64
}

#-------------------------------------------------------------------------------
# INSTANCE IAM PROFILE
#-------------------------------------------------------------------------------

resource "aws_iam_role" "ptfe" {
  name = "${local.id}-iam_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF

}

resource "aws_iam_instance_profile" "ptfe" {
  name = "${local.id}-iam_instance_profile"
  role = aws_iam_role.ptfe.name
}

data "aws_iam_policy_document" "ptfe" {
  statement {
    sid    = "AllowS3"
    effect = "Allow"

    resources = [
      "arn:aws:s3:::${var.license_s3_bucket_id}",
      "arn:aws:s3:::${var.license_s3_bucket_id}/*",
    ]

    actions = [
      "s3:*",
    ]
  }
}

resource "aws_iam_role_policy" "ptfe" {
  name   = "${local.id}-iam_role_policy"
  role   = aws_iam_role.ptfe.name
  policy = data.aws_iam_policy_document.ptfe.json
}

#-------------------------------------------------------------------------------
# SECURITY
#-------------------------------------------------------------------------------

resource "aws_security_group" "fe" {
  vpc_id = var.vpc_id

  ingress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = var.private_cidr_blocks
  }

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = var.public_cidr_blocks
  }

  ingress {
    protocol        = "tcp"
    from_port       = 443
    to_port         = 443
    security_groups = [var.alb_security_group_id]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

}

#-------------------------------------------------------------------------------
# INSTANCE
#-------------------------------------------------------------------------------

data "aws_ami" "debian" {
  most_recent = true

  filter {
    name   = "name"
    values = ["debian-stretch-hvm-x86_64-gp2-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  # https://wiki.debian.org/Cloud/AmazonEC2Image/Stretch
  owners = ["379101102735"]
}

resource "aws_launch_configuration" "fe" {

  # Scale
  image_id      = data.aws_ami.debian.id
  instance_type = var.aws_instance_type
  root_block_device {
    volume_size = 80
    volume_type = "gp2"
  }

  # Security
  key_name             = local.id
  security_groups      = [aws_security_group.fe.id]
  iam_instance_profile = aws_iam_instance_profile.ptfe.name

  # Bootstrap
  user_data = templatefile("${path.module}/user-data.tpl", {
    s3_region                   = var.region
    hostname                    = "terraform-${var.environment}.example.com"
    s3_bucket                   = var.license_s3_bucket_id
    pg_netloc                   = var.database_endpoint
    console_password            = var.database_password
    pg_password                 = var.database_password
    enc_password                = var.enc_password
    initial_admin_user_password = var.initial_admin_user_password
  })
}

resource "aws_autoscaling_group" "fe" {
  name                 = local.id
  desired_capacity     = var.aws_instance_count
  min_size             = var.aws_instance_count
  max_size             = var.aws_instance_count
  launch_configuration = aws_launch_configuration.fe.name
  vpc_zone_identifier  = var.private_subnet_ids
  target_group_arns    = [var.alb_target_group_arn]

  tag {
    key                 = "app"
    value               = "tfe"
    propagate_at_launch = true
  }

  tag {
    key                 = "role"
    value               = "fe"
    propagate_at_launch = true
  }
}

#-------------------------------------------------------------------------------
# BASTION
#-------------------------------------------------------------------------------

resource "aws_security_group" "bastion" {
  vpc_id = var.vpc_id

  ingress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = var.private_cidr_blocks
  }

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "bastion" {
  count                       = var.enable_bastion ? 1 : 0
  ami                         = data.aws_ami.debian.id
  instance_type               = "t2.nano"
  key_name                    = local.id
  subnet_id                   = element(var.public_subnet_ids, 0)
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  associate_public_ip_address = true

  connection {
    type        = "ssh"
    user        = "admin"
    host        = self.public_ip
    private_key = file(local.private_key_filename)
  }

  provisioner "file" {
    source      = local.private_key_filename
    destination = local.private_key_filename
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 400 ${local.private_key_filename}",
    ]
  }

  provisioner "file" {
    source      = "${path.module}/bootstrap.sh"
    destination = "bootstrap.sh"
  }
}
