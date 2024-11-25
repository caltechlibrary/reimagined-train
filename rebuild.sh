#!/bin/sh

multipass delete --purge archivesspace
multipass launch --name archivesspace --memory 4G --cpus 1 --disk 16G --cloud-init "$(dirname "$(readlink -f "$0")")"/archivesspace.yml
multipass mount "$(dirname "$(readlink -f "$0")")" archivesspace:/mnt/archivesspace
multipass exec archivesspace -- sudo /bin/sh /mnt/archivesspace/setup.sh

local_ip=$(multipass info archivesspace | grep "IPv4" | awk -F " " '{print $NF}')
echo "🧑‍💻 Staff Interface:"
echo "http://${local_ip}:8080"
echo "🤷 Public Interface:"
echo "http://${local_ip}:8081"
echo "🌞 Solr Interface:"
echo "http://${local_ip}:8983"
echo "😺 OAI Interface:"
echo "http://${local_ip}:8081"
echo "🤖 API Interface:"
echo "http://${local_ip}:8089"
echo "🧙 Adminer (MySQL) Interface:"
echo "http://${local_ip}/adminer"
