provider "aws" {
  region = "${var.zone}"
}

resource "aws_key_pair" "node_key" {
  key_name   = "${var.credentials["name"]}"
  public_key = "${file("${path.module}/public_keys/${var.credentials["name"]}.pub")}"
}

resource "aws_instance" "manager" {
  ami             = "${var.ami[var.zone]}"
  key_name        = "${var.credentials["name"]}"
  instance_type   = "t2.micro"
  security_groups = ["${aws_security_group.ssh.name}"]

  tags {
    Name = "swarm-manager"
  }

  provisioner "remote-exec" {
    script = "${path.module}/docker_install.sh"

    connection {
      type        = "ssh"
      user        = "${var.user}"
      private_key = "${file("~/.ssh/${var.credentials["name"]}")}"
    }
  }

  provisioner "remote-exec" {
    script = "${path.module}/init_swarm.sh"

    connection {
      type        = "ssh"
      user        = "${var.user}"
      private_key = "${file("~/.ssh/${var.credentials["name"]}")}"
    }
  }
}

resource "aws_instance" "node" {
  ami             = "${var.ami[var.zone]}"
  count           = "${var.node_count}"
  key_name        = "${var.credentials["name"]}"
  instance_type   = "t2.micro"
  security_groups = ["${aws_security_group.ssh.name}"]

  tags {
    Name = "swarm-worker-${count.index}"
  }

  provisioner "remote-exec" {
    script = "${path.module}/docker_install.sh"

    connection {
      type        = "ssh"
      user        = "${var.user}"
      private_key = "${file("~/.ssh/${var.credentials["name"]}")}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "docker swarm join --token ${data.external.get_tokens.result["worker"]} ${aws_instance.manager.public_ip}:2377",
    ]

    connection {
      type        = "ssh"
      user        = "${var.user}"
      private_key = "${file("~/.ssh/${var.credentials["name"]}")}"
    }
  }
}

resource "aws_security_group" "ssh" {
  name        = "allow_ssh"
  description = "Allows inbound ssh connections."

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2377
    to_port     = 2377
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 2377
    to_port     = 2377
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
