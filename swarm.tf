provider "aws" {
  region = "${var.zone}"
}

resource "aws_key_pair" "node_key" {
  key_name   = "${var.credentials["name"]}"
  public_key = "${file("${path.module}/credentials/public_keys/${var.credentials["name"]}.pub")}"
}


### VPC

resource "aws_vpc" "swarm" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags {
    Name = "swarm"
  }
}

resource "aws_subnet" "swarm" {
  cidr_block = "10.0.0.0/16"
  vpc_id = "${aws_vpc.swarm.id}"
  map_public_ip_on_launch = true

  tags {
    Name = "swarm"
  }
}

resource "aws_internet_gateway" "swarm" {
  vpc_id = "${aws_vpc.swarm.id}"

  tags {
    Name = "main"
  }
}

resource "aws_route_table" "swarm" {
  vpc_id = "${aws_vpc.swarm.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.swarm.id}"
  }

  tags {
    Name = "swarm"
  }
}

resource "aws_route_table_association" "swarm" {
  subnet_id      = "${aws_subnet.swarm.id}"
  route_table_id = "${aws_route_table.swarm.id}"
}


### Security Groups

resource "aws_security_group" "ssh" {
  name        = "allow_ssh"
  description = "Allows inbound ssh connections. Also allows all egress connections."
  vpc_id = "${aws_vpc.swarm.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "https" {
  name        = "allow_https"
  description = "Allows inbount http/s connections"
  vpc_id = "${aws_vpc.swarm.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "swarm_internal" {
  name        = "swarm_internal"
  description = "Allows all internal traffic between nodes in the swarm cluster"
  vpc_id = "${aws_vpc.swarm.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    self        = "true"
  }
}


### EFS

resource "aws_efs_file_system" "swarm" {
  tags {
    Name = "TerraSwarm"
  }
}

resource "aws_efs_mount_target" "swarm" {
  file_system_id = "${aws_efs_file_system.swarm.id}"
  subnet_id      = "${aws_subnet.swarm.id}"
  security_groups = ["${aws_security_group.swarm_internal.id}"]
}


### Instances

resource "aws_instance" "manager" {
  ami             = "${data.aws_ami.latest_ami.id}"
  count           = "${var.manager_count}"
  key_name        = "${var.credentials["name"]}"
  instance_type   = "t2.large"
  subnet_id      = "${aws_subnet.swarm.id}"
  vpc_security_group_ids = ["${aws_security_group.ssh.id}", "${aws_security_group.swarm_internal.id}", "${aws_security_group.https.id}"]

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

	# Mount efs to /mnt/efs
  provisioner "remote-exec" {
		inline = [
      "echo ${aws_efs_mount_target.swarm.id}", # Create dependency
			"sudo yum install -y nfs-utils",
			"sudo mkdir /mnt/efs",
			"sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 ${aws_efs_file_system.swarm.id}.efs.${var.zone}.amazonaws.com:/ /mnt/efs",
		]

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
  subnet_id      = "${aws_subnet.swarm.id}"
  security_groups = ["${aws_security_group.ssh.id}", "${aws_security_group.swarm_internal.id}"]

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

	# Mount efs to /mnt/efs
  provisioner "remote-exec" {
		inline = [
      "echo ${aws_efs_mount_target.swarm.id}", # Create dependency
			"sudo yum install -y nfs-utils",
			"sudo mkdir /mnt/efs",
			"sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 ${aws_efs_file_system.swarm.id}.efs.${var.zone}.amazonaws.com:/ /mnt/efs",
		]

    connection {
      type        = "ssh"
      user        = "${var.user}"
      private_key = "${file("${path.module}/credentials/private_keys/${var.credentials["name"]}")}"
    }
  }
}

