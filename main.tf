provider "aws" {
  alias  = "us"
  region = "us-west-2"
}

# Set Regions as AU, UK and US
variable "regions" {
  default = ["ap-southeast-2", "eu-west-1", "us-west-2"]
}

# Define environments
variable "environments" {
  default = ["testing", "production"]
}


# Iterate over each region
locals {
  region_configs = flatten([
    for region in var.regions : [
      for env in var.environments : {
        provider_alias = "${region}_${env}"
        vpc_name       = "vpc-${region}-${env}"
        subnet_name    = "subnet-${region}-${env}"
        sg_name        = "security-group-${region}-${env}"
        instance_name  = "ec2-instance-${region}-${env}"
      }
    ]
  ])
}

# Create VPC
resource "aws_vpc" "main" {
  for_each = { for config in local.region_configs : config.provider_alias => config }

  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = each.value["vpc_name"]
  }
}


resource "aws_subnet" "main" {
  for_each = { for config in local.region_configs : config.provider_alias => config }


  vpc_id                  = aws_vpc.main[each.key].id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${each.key}a"
  map_public_ip_on_launch = true

  tags = {
    Name = each.value["vpc_name"]
  }
}


# Create EC2 instance for Production environment

resource "aws_instance" "windows-server" {
  for_each                    = { for config in local.region_configs : config.provider_alias => config }
  ami                         = data.aws_ami.latest_windows_2022.id
  subnet_id                   = aws_subnet.main[each.key].id
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  security_groups             = [aws_security_group.aws-windows-sg[each.key].id]

  key_name  = aws_key_pair.key_pair.key_name
  user_data = data.template_file.windows-userdata.rendered

  # root disk
  root_block_device {
    volume_size           = 10
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }
  tags = {
    Name = each.value["instance_name"]
  }

}

# Define the security group for the Windows server
resource "aws_security_group" "aws-windows-sg" {
  for_each = { for config in local.region_configs : config.provider_alias => config }
  vpc_id   = aws_vpc.main[each.key].id
  tags = {
    Name = each.value["sg_name"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming HTTP connections"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
