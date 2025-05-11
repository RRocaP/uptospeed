#!/bin/bash
# Cloud Machine Setup Script
# This script clones the uptospeed repository and sets up a new machine

set -e  # Exit on error

echo "=== Uptospeed Cloud Machine Setup ==="
echo "This script will clone the repository and set up a new cloud machine"
echo

# Step 1: Install basic dependencies
echo "Step 1: Installing basic dependencies..."
sudo apt-get update
sudo apt-get install -y git curl wget unzip

# Step 2: Create project directory
echo "Step 2: Creating project directory..."
mkdir -p ~/projects
cd ~/projects

# Step 3: Clone the repository
echo "Step 3: Cloning the repository..."
if [ -d "uptospeed" ]; then
  echo "Directory already exists. Pulling latest changes..."
  cd uptospeed
  git pull
else
  git clone https://github.com/RRocaP/uptospeed.git
  cd uptospeed
fi

# Step 4: Make scripts executable
echo "Step 4: Making scripts executable..."
find . -name "*.sh" -exec chmod +x {} \;

# Step 5: Fix Docker installation (if needed)
echo "Step 5: Checking Docker installation..."
if ! command -v docker &>/dev/null; then
  echo "Docker not installed. Installing Docker..."
  ./fix-docker-install.sh
else
  echo "Docker already installed."
  docker --version
fi

# Step 6: Set up BuildKit (if needed)
echo "Step 6: Setting up Docker BuildKit..."
if ! docker buildx version | grep -q "github.com/docker/buildx"; then
  echo "BuildX not found or outdated. Setting up BuildKit..."
  ./docker-buildkit-workaround.sh
else
  echo "BuildX already installed."
  docker buildx version
fi

# Step 7: Configure firewall for Docker Cloud
echo "Step 7: Configuring firewall for Docker Cloud..."
sudo ./docker-cloud-firewall.sh

# Step 8: Test Docker Cloud connectivity
echo "Step 8: Testing Docker Cloud connectivity..."
./docker-cloud-access-test.sh

# Step 9: Get Docker Hub credentials
echo -e "\nStep 9: Checking Docker Hub login..."
if ! docker info 2>/dev/null | grep -q "Username"; then
  echo "You are not logged in to Docker Hub. Please login:"
  docker login
else
  echo "Already logged in to Docker Hub."
fi

# Step 10: Suggest next steps
echo -e "\n=== Setup Complete ==="
echo "Your environment is now ready! You can run the following commands:"
echo
echo "1. To build with Docker BuildKit:"
echo "   ./use-regular-docker.sh"
echo
echo "2. To build with Docker Cloud (if configured):"
echo "   docker buildx create --driver cloud yourusername/buildername"
echo "   docker buildx build --builder cloud-yourusername-buildername -t yourusername/tcga:latest ."
echo
echo "3. To run the setup script (install R, Python, etc.):"
echo "   ./setup.sh"
echo
echo "All files are located in: $(pwd)"
echo
echo "To quickly clone this repository on another machine, run:"
echo "curl -fsSL https://raw.githubusercontent.com/RRocaP/uptospeed/main/cloud-machine-setup.sh | bash"

# Return to the repository root
cd ~/projects/uptospeed