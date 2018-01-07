#!/bin/bash

set -e

if [ ! -z "${PIPEWORK_WAIT_IF}" ]; then
  chmod 700 /pipework
  /pipework --wait -i ${PIPEWORK_WAIT_IF}
fi

echo "Creating user ${CUPS_ADMIN_USERNAME}"
id ${CUPS_ADMIN_USERNAME} || adduser -H -S -G lpadmin ${CUPS_ADMIN_USERNAME}
echo "${CUPS_ADMIN_USERNAME}:${CUPS_ADMIN_PASSWORD}" | chpasswd

echo "Starting dbus"
/usr/bin/dbus-daemon --system
sleep 2

echo "Starting avahi"
/usr/sbin/avahi-daemon --no-drop-root &
sleep 5

echo "Starting cupsd"

touch /var/log/cups/error_log
chown root:lp /var/log/cups/error_log
tail -f /var/log/cups/error_log &

/usr/sbin/cupsd -f
