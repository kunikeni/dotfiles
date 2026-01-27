#!/usr/bin/env bash
set -e

echo "== Updating package lists =="
sudo apt update -y

echo "== Install prerequisites =="
sudo apt install -y curl unzip gnupg lsb-release ca-certificates

#######################################
# AWS CLI
#######################################
echo "== Installing AWS CLI =="
sudo snap install aws-cli --classic
echo "aws version: $(aws --version)"

#######################################
# ctop
#######################################
echo "== Installing ctop =="
CTOP_VERSION=$(curl -s "https://api.github.com/repos/bcicen/ctop/releases/latest" | grep tag_name | cut -d '"' -f4)
curl -LO https://github.com/bcicen/ctop/releases/download/${CTOP_VERSION}/ctop-${CTOP_VERSION#v}-linux-amd64
sudo install ctop-${CTOP_VERSION#v}-linux-amd64 /usr/local/bin/ctop
echo "ctop version: $(ctop --version)"

#######################################
# docker
#######################################
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo groupadd docker
sudo usermod -aG docker $(whoami)
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

#######################################
# starship
#######################################
echo "== Installing starship =="
curl -sS https://starship.rs/install.sh | sh -s -- --yes
echo "starship version: $(starship --version)"

#######################################
# Claude Code CLI (official sh installer)
#######################################
echo "== Installing Claude Code CLI =="
curl -fsSL https://claude.ai/install.sh | bash

# PATH に ~/.local/bin が無い場合に備えて明示
if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
fi

echo "claude path: $(command -v claude || echo 'not found')"
