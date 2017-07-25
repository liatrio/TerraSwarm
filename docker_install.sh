#
# Name - docker_install.sh
# Desc - this script will be used to install Docker on the Amazon Linux AMI
#        instance. It follows along with the installation guide from Docker,
#        found at https://docs.docker.com/engine/installation/
#

sudo dd if=/dev/zero of=/var/myswap bs=1M count=2048
sudo mkswap /var/myswap
sudo chmod 0600 /var/myswap
sudo swapon /var/myswap
sudo sh -c 'echo "/var/myswap   swap   swap   defaults  0 0" >> /etc/fstab'

# Prepare for installation.
sudo yum update -y

# Install Docker and jq (for JSON parsing).
sudo yum install -y docker jq git

# Update the default maximum number of file descriptors that a container can have
sudo sed -i 's/1024:4096/32000:32000/g' /etc/sysconfig/docker

# Start the Docker service.
sudo service docker start

# Add ec2-user to the docker group to execute Docker commands without sudo.
sudo usermod -a -G docker ec2-user
