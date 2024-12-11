#!/bin/sh

if [ "$#" -gt 2 ]; then
    echo "USAGE: /bin/sh $0 [db [<ISO DATE>]]"
    echo "EXAMPLES:"
    echo "    /bin/sh $0 db  # restores the latest db backup"
    echo "    /bin/sh $0 db 2023-02-18  # restores the db backup from the specified date"
    exit 1
fi

multipass start as4
if [ "$(multipass info as4 | grep "Mounts" | awk -F " " '{print $NF}')" = "--" ]; then
    multipass mount "$(dirname "$(readlink -f "$0")")" as4:/mnt/as4
fi
if [ -n "$2" ]; then
    multipass exec as4 -- sudo /bin/sh /mnt/as4/db.sh "$2"
else
    multipass exec as4 -- sudo /bin/sh /mnt/as4/db.sh
fi
multipass exec as4 -- sudo /opt/archivesspace/archivesspace.sh start

local_ip=$(multipass info as4 | grep "IPv4" | awk -F " " '{print $NF}')
echo "🧑‍💻 Staff Interface:"
echo "http://${local_ip}:8080"
echo "🤷 Public Interface:"
echo "http://${local_ip}:8081"
echo "🌞 Solr Interface:"
echo "http://${local_ip}:8983"
echo "😺 OAI Interface:"
echo "http://${local_ip}:8082"
echo "🤖 API Interface:"
echo "http://${local_ip}:8089"
echo "🧙 Adminer (MySQL) Interface:"
echo "http://${local_ip}/adminer"
