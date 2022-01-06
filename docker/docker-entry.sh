#! /bin/bash

set -e

VOLUME_DATA=/home/vividboarder/.data
[ -d "$VOLUME_DATA/nvim/backup" ] || mkdir -p "$VOLUME_DATA/nvim/backup"
[ -d "$XDG_CONFIG_HOME/nvim/backup" ] || ln -s "$VOLUME_DATA/nvim/backup" "$XDG_CONFIG_HOME/nvim/backup"

if [ "$1" == "bash" ]; then
    exec "$@"
else
    exec nvim "$@"
fi
