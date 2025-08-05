#!/bin/bash

set -euo pipefail

if [[ -n ${DBUS_SESSION_BUS_ADDRESS+x} ]] ; then
  keyring $@
  exit
fi

# Run in independent dbus session
function cleanup() {
  kill ${DBUS_SESSION_BUS_PID}
}
eval $(dbus-launch --sh-syntax)
trap cleanup EXIT INT TERM

# In CLI we help gnome keyring to unlock
if [[ -z ${DISPLAY+x} ]] ; then
  keyring_password=$(python3 -c "import getpass;print(getpass.getpass())")
  eval $(echo -n "$keyring_password" | gnome-keyring-daemon --unlock -c secrets)
fi

keyring $@
