#
# Name - generate_key.sh
# Desc - this script generates an rsa keypair, changes the permissions and
#        moves it to ~/.ssh. It then generates a Terraform file that will allow
#        us to use the new keys wihtout further configuration.
#

if [ -z "$1" ];
then
  KEYNAME=terraswarm
else
  KEYNAME=$1
fi

ssh-keygen -b 4096 -t rsa -N '' -f $KEYNAME

chmod 400 $KEYNAME

if [ ! -d "public_keys" ]; then
  mkdir public_keys
fi

mv $KEYNAME ~/.ssh/
mv $KEYNAME.pub public_keys/

printf "variable \"credentials\"{\ntype=\"map\"\ndefault={\nname=\"$KEYNAME\"\nlocation=\"~/.ssh\"\n}\n}\n" > credentials.tf

terraform fmt
