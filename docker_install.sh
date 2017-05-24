#
# Name - docker_install.sh
# Desc - this script will be used to install Docker on a CentOS or Red Hat
#        instance. It follows along with the installation guide from Docker,
#        found at https://docs.docker.com/engine/installation/
#

# Prepare for installation.
sudo yum update -y

# Install Docker.
sudo yum install -y docker

# Start the Docker service.
sudo service docker start

# Add ec2-user to the docker group to execute Docker commands without sudo.
sudo usermod -a -G docker ec2-user
