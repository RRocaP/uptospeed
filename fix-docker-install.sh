#!/bin/bash
# Script to fix Docker installation issues and install the latest version
set -e

echo "=== Fixing Docker Installation Issues ==="
echo "This script will remove conflicting packages and install Docker properly"

# Step 1: Remove conflicting packages
echo -e "\n[Step 1] Removing conflicting packages..."
sudo apt-get remove -y docker docker-engine docker.io containerd containerd.io runc || true

# Step 2: Clean any residual packages
echo -e "\n[Step 2] Cleaning up the system..."
sudo apt-get autoremove -y
sudo apt-get clean

# Step 3: Update package lists
echo -e "\n[Step 3] Updating package lists..."
sudo apt-get update

# Step 4: Install dependencies
echo -e "\n[Step 4] Installing required dependencies..."
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Step 5: Set up the Docker repository
echo -e "\n[Step 5] Adding Docker's official GPG key..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Add the repository
echo -e "\n[Step 6] Setting up the Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Step 7: Update apt again with the new repository
echo -e "\n[Step 7] Updating package lists with Docker repository..."
sudo apt-get update

# Step 8: Install Docker
echo -e "\n[Step 8] Installing Docker Engine and related tools..."
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-buildx-plugin

# Step 9: Add current user to docker group
echo -e "\n[Step 9] Adding current user to the docker group..."
sudo usermod -aG docker $USER
echo "NOTE: You'll need to log out and back in for group changes to take effect."

# Step 10: Verify installation
echo -e "\n[Step 10] Verifying Docker installation..."
sudo docker --version
sudo docker buildx version

echo -e "\n=== Docker installation completed ==="
echo "If you see version information above, Docker was installed successfully."
echo "Please log out and log back in for group membership changes to take effect."
echo "After logging back in, you can run docker commands without sudo."
echo "Example: docker run hello-world"