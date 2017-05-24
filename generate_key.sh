#
# Name - generate_key.sh
# Desc - this script generates an rsa keypair, changes the permissions and
#        moves it to ~/.ssh. It then generates a Terraform file that will allow
#        us to use the new keys wihtout further configuration.
#

ssh-keygen -b 4096 -t rsa -N '' -f ${1}

chmod 400 ${1}

if [ ! -d "public_keys" ]; then
  mkdir public_keys
fi

mv ${1} ~/.ssh/
mv ${1}.pub public_keys/

printf "variable \"credentials\"{\ntype=\"map\"\ndefault={\nname=\"${1}\"\nlocation=\"~/.ssh\"\n}\n}\n" > credentials.tf

terraform fmt
