#!/bin/sh

multipass delete --purge as4
multipass launch --memory 4G --cpus 1 --disk 16G --timeout 600 --name as4 --cloud-init "$(dirname "$(readlink -f "$0")")"/as4.yml
multipass mount "$(dirname "$(readlink -f "$0")")" as4:/mnt/as4
multipass exec as4 -- sudo /bin/sh /mnt/as4/setup.sh

local_ip=$(multipass info as4 | grep "IPv4" | awk -F " " '{print $NF}')
printf "\n🧑‍💻 Staff Interface:\n"
echo "http://${local_ip}:8080"
printf "\n🤷 Public Interface:\n"
echo "http://${local_ip}:8081"
printf "\n🌞 Solr Interface:\n"
echo "http://${local_ip}:8983"
printf "\n😺 OAI Interface:\n"
echo "http://${local_ip}:8082"
printf "\n🤖 API Interface:\n"
echo "http://${local_ip}:8089"
printf "\n🧙 Adminer (MySQL) Interface:\n"
echo "http://${local_ip}/adminer"
