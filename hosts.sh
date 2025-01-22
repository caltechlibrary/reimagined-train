#!/bin/sh

if [ -p /dev/stdin ]; then
    IP="$(cat)"
else
    IP="$1"
fi

echo "🌐 IP Address:"
echo "$IP"

if grep -q archivesspace.local /etc/hosts; then
    sudo sed -i".bak" "/archivesspace.local/d" /etc/hosts
fi

sudo -- sh -c -e "echo '${IP}\tarchivesspace.local' >> /etc/hosts";

if ! grep -q "$IP" /etc/hosts; then
    echo "⛔️ ERROR failed to add ${IP} archivesspace.local to /etc/hosts";
fi
