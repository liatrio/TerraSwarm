provider "aws" {
  region = "${var.zone}"
}

resource "aws_key_pair" "node_key" {
  key_name   = "${var.credentials["name"]}"
  public_key = "${file("public_keys/${var.credentials["name"]}.pub")}"
}

resource "aws_instance" "manager" {
  ami             = "${var.ami[var.zone]}"
  key_name        = "${var.credentials["name"]}"
  instance_type   = "t2.micro"
  security_groups = ["${aws_security_group.ssh.name}"]

  provisioner "remote-exec" {
    script = "./docker_install.sh"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${file("~/.ssh/${var.credentials["name"]}")}"
    }
  }
}

resource "aws_security_group" "ssh" {
  name = "allow_ssh"
  description = "Allows inbound ssh connections."

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
