variable "user" {
  type    = "string"
  default = "ec2-user"
}

variable "zone" {
  type    = "string"
  default = "us-west-2"
}

data "aws_ami" "latest_ami" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  name_regex = "^amzn-ami-hvm-*"
}

variable "worker_count" {
  type    = "string"
  default = "1"
}

variable "manager_count" {
  type    = "string"
  default = "1"
}

data "external" "get_tokens" {
  program = ["bash", "${path.module}/get_tokens.sh"]

  query = {
    user    = "${var.user}"
    address = "${aws_instance.manager.public_ip}"
    keypath = "${path.module}/credentials/private_keys/${var.credentials["name"]}"
  }
}
