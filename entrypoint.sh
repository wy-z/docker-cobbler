#!/bin/bash

set -e

#
# Init configuration
#

SERVER="${SERVER:-${SERVER_IP_V4}}"
if [ -z "$SERVER" ]; then
    echo "env 'SERVER' is required."
    exit 1
fi
if [ -z "$SERVER_IP_V4" ] && [ -z "$SERVER_IP_V6" ]; then
    echo "env ['SERVER_IP_V4', 'SERVER_IP_V6'] require at least one."
    exit 1
fi
if [ -z "$ROOT_PASSWORD" ]; then
    echo "env 'ROOT_PASSWORD' is required."
    exit 1
fi

# set server config
sed -i "s/^server: 127.0.0.1/server: $SERVER/g" /etc/cobbler/settings.yaml
if [ -n "${SERVER_IP_V4}" ]; then
    sed -i "s/^next_server_v4: 127.0.0.1/next_server_v4: $SERVER_IP_V4/g" /etc/cobbler/settings.yaml
fi
if [ -n "${SERVER_IP_V6}" ]; then
    sed -i "s/^next_server_v6: ::1/next_server_v6: $SERVER_IP_V6/g" /etc/cobbler/settings.yaml
fi
CRYPTED_PASSWORD=$(openssl passwd -1 "$ROOT_PASSWORD")
sed -i "s#^default_password.*#default_password_crypted: \"$CRYPTED_PASSWORD\"#g" /etc/cobbler/settings.yaml
# set menu title
if [ -n "${MENU_TITLE}" ]; then
    sed -ri "s#^MENU TITLE Cobbler.+#MENU TITLE $MENU_TITLE#g" /etc/cobbler/boot_loader_conf/pxe_menu.template
    sed -ri "s#^MENU TITLE Cobbler.+#MENU TITLE $MENU_TITLE#g" /etc/cobbler/iso/buildiso.template
fi

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
    tail -n +1 -f /var/log/cobbler/cobbler.log
) &
exec /usr/sbin/init
