#!/bin/sh

if [ "$(whoami)" != "root" ]; then
    echo "⛔️ ERROR this script must be run with sudo" >&2
    exit 1
fi

sudo -u "${SUDO_USER:-$USER}" multipass delete --purge archivesspace
sudo -u "${SUDO_USER:-$USER}" multipass launch --name archivesspace --memory 4G --cpus 1 --disk 16G --cloud-init "$(dirname "$(readlink -f "$0")")"/archivesspace.yml
sudo -u "${SUDO_USER:-$USER}" multipass mount "$(dirname "$(readlink -f "$0")")" archivesspace:/mnt/archivesspace
sudo -u "${SUDO_USER:-$USER}" multipass exec archivesspace -- sudo sh /mnt/archivesspace/setup.sh

sudo -u "${SUDO_USER:-$USER}" multipass info archivesspace | grep 'IPv4' | awk -F ' ' '{print $NF}' | sh hosts.sh

echo "🧙 Staff Interface:"
echo "http://archivesspace.local:8080"
echo "🤷 Public Interface:"
echo "http://archivesspace.local:8081"
echo "🌞 Solr Interface:"
echo "http://archivesspace.local:8983"
echo "😺 OAI Interface:"
echo "http://archivesspace.local:8081"
echo "🤖 API Interface:"
echo "http://archivesspace.local:8089"
echo "🧙 Adminer (MySQL) Interface:"
echo "http://archivesspace.local/adminer"
