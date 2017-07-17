# **TerraSwarm** <img align="right" src="media/liatrio.png">

TerraSwarm is an application that launches a specified number of AWS instances and creates a Docker Swarm from them. TerraSwarm simplifies this process into a couple commands and is parameterized so that very little customization is needed to generate the swarm.

You will need to have TerraForm >= 9.11 installed on your host machine, as well as have an Amazon Web Services IAM user with permissions to use EC2. You can pass these variables to TerraForm when you run the apply command, or you can have these values specified in a file in ~/.aws/credentials.

An example credentials file can be found below.

------

[default]
aws_access_key_id = <ACCESS_KEY_HERE>
aws_secret_access_key = <SECRET_KEY_HERE>

------

To begin, run the generate_key.sh script to create an initialize a key pair for TerraSwarm.

------

./generate_key <KEY_NAME>

------

Afterwards, run the TerraForm apply command to have the Docker Swarm created.

------

terraform apply

------

You can customize how many workers are launched in variables.tf. If you want to launch this on different AMIs, you will need to change the AMI in variables.tf as well as update the docker_install.sh script to work for that OS.
