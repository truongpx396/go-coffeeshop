#!/usr/bin/env bash
set -euo pipefail

# install apt-add-repository
sudo apt-get update
sudo apt-get install wget gpg coreutils

apt update 
apt install software-properties-common -y
apt update


echo "Adding HashiCorp GPG key and repo..."
# curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
# apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
# apt-get update
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# install cni plugins https://www.nomadproject.io/docs/integrations/consul-connect#cni-plugins
echo "Installing cni plugins..."
curl -L -o cni-plugins.tgz "https://github.com/containernetworking/plugins/releases/download/v1.1.1/cni-plugins-linux-$( [ $(uname -m) = aarch64 ] && echo arm64 || echo amd64)"-v1.1.1.tgz
sudo mkdir -p /opt/cni/bin
sudo tar -C /opt/cni/bin -xzf cni-plugins.tgz
sudo rm ./cni-plugins.tgz

echo "Installing Consul..."
sudo apt-get install consul -y

echo "Installing Nomad..."
# sudo apt-get install nomad -y
sudo apt-get update
sudo apt-get install nomad -y

echo "Installing Vault..."
sudo apt-get install vault -y

# # configuring environment
# sudo -H -u root nomad -autocomplete-install
# sudo -H -u root consul -autocomplete-install
# sudo -H -u root vault -autocomplete-install
# sudo tee -a /etc/environment <<EOF
# export VAULT_ADDR=http://localhost:8200
# export VAULT_TOKEN=root
# EOF

source /etc/environment

# WSL2-hack - Nomad cannot run on wsl2 image, then we need to work-around
sudo mkdir -p /lib/modules/$(uname -r)/
echo '_/bridge.ko' | sudo tee -a /lib/modules/$(uname -r)/modules.builtin