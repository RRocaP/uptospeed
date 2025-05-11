#!/bin/bash
# Minimal Docker installation script that avoids containerd conflicts
set -e

echo "=== Minimal Docker Installation Without Conflicts ==="

# Remove conflicting packages
sudo apt-get remove -y docker docker-engine docker.io containerd runc || true
sudo apt-get autoremove -y

# Update and install dependencies
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

# Add Docker repository
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Pin versions to avoid conflicts
cat << EOF | sudo tee /etc/apt/preferences.d/docker
Package: containerd.io
Pin: version 1.6.21-1
Pin-Priority: 1001

Package: docker-ce
Pin: version 5:24.0.5-1~ubuntu.22.04~jammy
Pin-Priority: 1001

Package: docker-ce-cli
Pin: version 5:24.0.5-1~ubuntu.22.04~jammy
Pin-Priority: 1001
EOF

# Update and install Docker with pinned versions
sudo apt-get update
sudo apt-get install -y docker-ce=5:24.0.5-1~ubuntu.22.04~jammy docker-ce-cli=5:24.0.5-1~ubuntu.22.04~jammy containerd.io=1.6.21-1

# Install buildx plugin separately
sudo mkdir -p /usr/local/lib/docker/cli-plugins/
sudo curl -SL https://github.com/docker/buildx/releases/download/v0.11.2/buildx-v0.11.2.linux-amd64 -o /usr/local/lib/docker/cli-plugins/docker-buildx
sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-buildx

# Set up current user
sudo usermod -aG docker $USER
echo "NOTE: You'll need to log out and back in for group changes to take effect."

# Verify installation
echo -e "\n=== Docker installation verification ==="
sudo docker --version
sudo docker buildx version

echo -e "\n=== Installation completed ==="
echo "Please log out and log back in for group membership changes to take effect."