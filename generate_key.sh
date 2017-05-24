ssh-keygen -b 4096 -t rsa -N '' -f ${1}

chmod 400 ${1}
mv ${1} ~/.ssh/

printf "variable \"credentials\"{\ntype=\"map\"\ndefault={\nname=\"${1}\"\nlocation=\"~/.ssh\"\n}\n}\n" > credentials.tf

terraform fmt
