provider "aws" {
  region = "${var.zone}"
}

resource "aws_instance" "manager" {
  ami             = "${var.ami[var.zone]}"
  key_name        = "${var.credentials["name"]}"
  instance_type   = "t2.micro"
  security_groups = ["${aws_security_group.ssh.name}"]
}

resource "aws_security_group" "ssh" {
  name = "allow_ssh"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
