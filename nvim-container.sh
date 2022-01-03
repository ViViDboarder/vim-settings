#! /bin/bash

set -ex

if ! docker image ls -q nvim > /dev/null ;then
    echo "no nvim image found"
    exit 1
fi

container_name=nvim-$USER

if ! docker inspect "${container_name}-home" > /dev/null ; then
    docker volume create "${container_name}-home"
fi

docker run --interactive --rm --tty \
    --name "$container_name" \
    --env "VIM_COLOR=$VIM_COLOR" \
    --volume "${container_name}-home:/home/vividboarder/.data" \
    --volume "$(pwd):/home/vividboarder/data" \
    --workdir /home/vividboarder/data \
    --entrypoint /docker-entry.sh \
    --user "vividboarder:$(id -g)" \
    --group-add users \
    vividboarder/my-neovim nvim "$@"
