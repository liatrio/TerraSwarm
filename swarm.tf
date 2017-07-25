provider "aws" {
  region = "${var.zone}"
}

resource "aws_key_pair" "node_key" {
  key_name   = "${var.credentials["name"]}"
  public_key = "${file("${path.module}/credentials/public_keys/${var.credentials["name"]}.pub")}"
}

resource "aws_instance" "manager" {
  ami             = "${data.aws_ami.latest_ami.id}"
  count           = "${var.manager_count}"
  key_name        = "${var.credentials["name"]}"
  instance_type   = "t2.large"
  security_groups = ["${aws_security_group.ssh.name}", "${aws_security_group.default_vpc_docker.name}"]

  root_block_device {
    volume_size = 20
  }

  tags {
    Name    = "swarm-manager-${count.index}"
    Project = "LDOP"
  }

  provisioner "remote-exec" {
    script = "${path.module}/docker_install.sh"

    connection {
      type        = "ssh"
      user        = "${var.user}"
      private_key = "${file("${path.module}/credentials/private_keys/${var.credentials["name"]}")}"
    }
  }

  provisioner "remote-exec" {
    script = "${path.module}/init_swarm.sh"

    connection {
      type        = "ssh"
      user        = "${var.user}"
      private_key = "${file("${path.module}/credentials/private_keys/${var.credentials["name"]}")}"
    }
  }
}

resource "aws_instance" "node" {
  ami             = "${data.aws_ami.latest_ami.id}"
  count           = "${var.worker_count}"
  key_name        = "${var.credentials["name"]}"
  instance_type   = "t2.large"
  security_groups = ["${aws_security_group.ssh.name}", "${aws_security_group.default_vpc_docker.name}"]

  root_block_device {
    volume_size = 20
  }

  tags {
    Name    = "swarm-worker-${count.index}"
    Project = "LDOP"
  }

  provisioner "remote-exec" {
    script = "${path.module}/docker_install.sh"

    connection {
      type        = "ssh"
      user        = "${var.user}"
      private_key = "${file("${path.module}/credentials/private_keys/${var.credentials["name"]}")}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "docker swarm join --token ${data.external.get_tokens.result["worker"]} ${aws_instance.manager.public_ip}:2377",
    ]

    connection {
      type        = "ssh"
      user        = "${var.user}"
      private_key = "${file("${path.module}/credentials/private_keys/${var.credentials["name"]}")}"
    }
  }
}

resource "aws_default_vpc" "default" {
  tags {
    Name    = "Default vpc."
    Project = "LDOP"
  }
}

resource "aws_security_group" "default_vpc_docker" {
  name        = "default_vpc"
  description = "Allows Docker traffic through default VPC."
  vpc_id      = "${aws_default_vpc.default.id}"

  ingress {
    from_port   = 2377
    to_port     = 2377
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
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 389
    to_port     = 389
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 389
    to_port     = 389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 4789
    to_port     = 4789
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 4789
    to_port     = 4789
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5601
    to_port     = 5601
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 7946
    to_port     = 7946
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 7946
    to_port     = 7946
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
    from_port   = 389
    to_port     = 389
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 389
    to_port     = 389
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
    from_port   = 4789
    to_port     = 4789
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 4789
    to_port     = 4789
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 5601
    to_port     = 5601
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 7946
    to_port     = 7946
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 7946
    to_port     = 7946
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
