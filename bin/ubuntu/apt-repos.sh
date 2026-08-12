#!/bin/sh
# mise.ubuntu.toml の [bootstrap.hooks.pre-packages] から呼ばれる。
set -eu

codename="$(. /etc/os-release && echo "$VERSION_CODENAME")"
arch="$(dpkg --print-architecture)"

sudo install -m 0755 -d /etc/apt/keyrings

if [ ! -f /etc/apt/keyrings/docker.asc ]; then
    echo "==> registering docker apt repository"
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    echo "deb [arch=${arch} signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu ${codename} stable" |
        sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
fi

sudo apt-get update
