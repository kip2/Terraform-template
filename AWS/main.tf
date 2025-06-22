provider "aws" {
  region  = "ap-northeast-1"
  profile = "exercise-user"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["self", "amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

locals {
  exercise_tags = {
    Project     = "exercise"
    Environment = "dev"
    Owner       = "exercise-user"
  }
}


resource "aws_instance" "example" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"

  tags = merge(
    local.exercise_tags,
    { Name = "exercise-instance" }
  )
}
