#!/bin/bash

set -e

#
# Init configuration
#

if [[ -z "$SERVER_IP" ]]; then
    echo "env 'SERVER_IP' is required."
    exit 1
elif [[ -z "$ROOT_PASSWORD" ]]; then
    echo "env 'ROOT_PASSWORD' is required."
    exit 1
fi
PASSWORD=$(openssl passwd -1 "$ROOT_PASSWORD")
sed -i "s/^server: 127.0.0.1/server: $SERVER_IP/g" /etc/cobbler/settings.yaml
sed -i "s/^next_server_v4: 127.0.0.1/next_server_v4: $SERVER_IP/g" /etc/cobbler/settings.yaml
sed -i "s#^default_password.*#default_password_crypted: \"$PASSWORD\"#g" /etc/cobbler/settings.yaml

#
# Init data volumes
#

for v in $DATA_VOLUMES; do
    # shellcheck disable=SC2086
    if [ -z "$(ls -A $v)" ]; then
        mv ${v}.save/* $v
    fi
done

#
# Fix https://github.com/cobbler/cobbler/issues/3016
#

chmod g+rw /etc/cobbler /etc/cobbler/settings.yaml /etc/cobbler/modules.conf
usermod -aG root apache

#
# Boot cobbler
#

(
    sleep 6
    cobbler sync
) &

exec /usr/sbin/init
