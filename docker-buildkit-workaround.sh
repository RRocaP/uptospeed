#!/bin/bash
# Docker BuildKit Workaround Script
# This script sets up a BuildKit container and configures it for use with Docker

set -e
echo "=== Setting up BuildKit Container for Docker ===\n"

# Step 1: Check if Docker is running
echo "[Step 1] Checking Docker status..."
if ! docker info &>/dev/null; then
  echo "Docker is not running. Starting Docker..."
  sudo systemctl start docker
  sleep 2
fi
echo "Docker is running. Continuing...\n"

# Step 2: Remove any existing buildkit containers
echo "[Step 2] Removing any existing BuildKit containers..."
docker rm -f buildkit-container &>/dev/null || true
echo "Done.\n"

# Step 3: Create a BuildKit container
echo "[Step 3] Creating BuildKit container..."
docker run -d --name buildkit-container \
  --privileged \
  -p 1234:1234 \
  --restart always \
  moby/buildkit:latest \
  --addr tcp://0.0.0.0:1234
echo "BuildKit container created and running on port 1234.\n"

# Step 4: Wait for BuildKit to start
echo "[Step 4] Waiting for BuildKit to initialize..."
sleep 3
echo "BuildKit should be ready now.\n"

# Step 5: Create a BuildX builder that uses the BuildKit container
echo "[Step 5] Creating BuildX builder using remote driver..."
docker buildx rm buildkit-builder &>/dev/null || true
docker buildx create \
  --name buildkit-builder \
  --driver remote \
  tcp://localhost:1234
echo "BuildX builder 'buildkit-builder' created.\n"

# Step 6: Set the builder as default
echo "[Step 6] Setting 'buildkit-builder' as the default builder..."
docker buildx use buildkit-builder
echo "Default builder set.\n"

# Step 7: Verify the setup
echo "[Step 7] Verifying the setup..."
docker buildx inspect --bootstrap
echo "\nBuildKit setup complete!"

# Step 8: Examples of how to use the builder
echo "\n=== How to Use Your New Builder ===\n"
echo "# Build a Docker image"
echo "docker buildx build -t myimage:latest ."
echo 
echo "# Build and load into Docker"
echo "docker buildx build --load -t myimage:latest ."
echo
echo "# Build and push to Docker Hub"
echo "docker buildx build --push -t username/myimage:latest ."
echo
echo "# Build for multiple platforms"
echo "docker buildx build --platform linux/amd64,linux/arm64 --push -t username/myimage:latest ."

echo "\n=== Docker BuildX Setup Complete ===\n"
echo "Now you can build Docker images with enhanced features without needing the cloud driver."
echo "Use 'docker buildx build' instead of 'docker build' for all your builds."