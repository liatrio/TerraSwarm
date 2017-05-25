set -e

eval "$(jq -r '@sh "user=\(.user) address=\(.address) keypath=\(.keypath)"')"

WORKER="$(ssh -o StrictHostKeyChecking=no -i $keypath $user@$address "sudo docker swarm join-token worker --quiet")"
MANAGER="$(ssh -o StrictHostKeyChecking=no -i $keypath $user@$address "sudo docker swarm join-token manager --quiet")"

echo "{\"worker\":\"${WORKER}\",\"manager\":\"${MANAGER}\"}"
