locals {
  common_tags = {
    Env     = "production"
    Project = "toucan"
  }
}

resource "aws_vpc" "ami_exp" {
  cidr_block                       = "10.0.0.0/16"
  enable_dns_hostnames             = true
  assign_generated_ipv6_cidr_block = false

  tags = local.common_tags
}

resource "aws_internet_gateway" "ami_exp" {
  vpc_id = aws_vpc.ami_exp.id
  tags   = local.common_tags
}

resource "aws_subnet" "restricted" {
  cidr_block              = cidrsubnet(aws_vpc.ami_exp.cidr_block, 8, 0)
  vpc_id                  = aws_vpc.ami_exp.id
  map_public_ip_on_launch = true
  tags                    = local.common_tags

}

resource "aws_subnet" "open" {
  cidr_block              = cidrsubnet(aws_vpc.ami_exp.cidr_block, 8, 1)
  vpc_id                  = aws_vpc.ami_exp.id
  map_public_ip_on_launch = true
  tags                    = local.common_tags
}

resource "aws_route_table" "internet" {
  vpc_id = aws_vpc.ami_exp.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ami_exp.id
  }

  tags = local.common_tags
}

resource "aws_route_table_association" "open" {
  subnet_id      = aws_subnet.open.id
  route_table_id = aws_route_table.internet.id
}

resource "aws_route_table_association" "restricted" {
  subnet_id      = aws_subnet.restricted.id
  route_table_id = aws_route_table.internet.id
}

resource "aws_security_group" "allow_internal_ingress" {
  name   = "allow-internal-ingress"
  vpc_id = aws_vpc.ami_exp.id

  ingress {
    cidr_blocks = [aws_vpc.ami_exp.cidr_block]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  tags = local.common_tags
}

resource "aws_security_group" "allow_all" {
  name   = "allow-all"
  vpc_id = aws_vpc.ami_exp.id

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  tags = local.common_tags
}

data "aws_ami" "canary" {
  owners = ["506090309989"] # Thinkst

  filter {
    name   = "image-id"
    values = ["ami-00495588d2a22109a"]
  }
}

data "aws_ami" "ubuntu" {
  owners      = ["099720109477"] # Canonical
  most_recent = true

  filter {
    # We must be more specific here than "ubuntu-*" because Canonical
    # publish new versions of old releases.
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

data "aws_ami" "arch" {
  owners      = ["093273469852"] # Uplink Labs
  most_recent = true

  filter {
    name   = "name"
    values = ["arch-linux-hvm-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

data "template_file" "user_data" {
  template = file("${path.root}/data/init.yaml")
}

resource "aws_instance" "canary" {
  ami                    = data.aws_ami.canary.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_internal_ingress.id]
  subnet_id              = aws_subnet.restricted.id
  tags                   = merge(local.common_tags, { "Name" = "toucan" })
}

resource "aws_instance" "arch" {
  ami                    = data.aws_ami.arch.id
  instance_type          = "t2.nano"
  vpc_security_group_ids = [aws_security_group.allow_all.id]
  subnet_id              = aws_subnet.open.id
  key_name               = aws_key_pair.local.key_name
  user_data              = data.template_file.user_data.rendered
  tags                   = merge(local.common_tags, { "Name" = "arch" })
}

resource "aws_instance" "ubuntu" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.nano"
  vpc_security_group_ids = [aws_security_group.allow_all.id]
  subnet_id              = aws_subnet.open.id
  key_name               = aws_key_pair.local.key_name
  user_data              = data.template_file.user_data.rendered
  tags                   = merge(local.common_tags, { "Name" = "ubuntu" })
}

resource "aws_key_pair" "local" {
  key_name   = "local_key"
  public_key = file("~/.ssh/id_rsa.pub")
  tags       = local.common_tags
}
