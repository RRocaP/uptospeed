#!/bin/bash
# Script to build with regular Docker instead of BuildX Cloud
set -e

echo "=== Building with Standard Docker and BuildKit ===\n"

# Step 1: Enable BuildKit for standard Docker
echo "[Step 1] Enabling BuildKit for Docker..."
export DOCKER_BUILDKIT=1
echo "Done.\n"

# Step 2: Build the Docker image
echo "[Step 2] Building the Docker image..."
echo "Running: docker build -t rrocap670/tcga:latest -f Dockerfile.fixed-v2 ."
docker build -t rrocap670/tcga:latest -f Dockerfile.fixed-v2 .
echo "Build completed.\n"

# Step 3: Tag the image
echo "[Step 3] Tagging the Docker image..."
echo "Running: docker tag rrocap670/tcga:latest rrocap670/tcga:$(date +%Y%m%d)"
docker tag rrocap670/tcga:latest rrocap670/tcga:$(date +%Y%m%d)
echo "Done.\n"

# Step 4: Push to Docker Hub (if desired)
echo "[Step 4] Pushing to Docker Hub..."
echo "Do you want to push the images to Docker Hub? (y/n)"
read -p "> " push_choice

if [[ "$push_choice" == "y" || "$push_choice" == "Y" ]]; then
  # Check if logged in
  if ! docker info | grep -q "Username"; then
    echo "You are not logged in to Docker Hub. Please login:"
    docker login
  fi
  
  echo "Pushing images to Docker Hub..."
  docker push rrocap670/tcga:latest
  docker push rrocap670/tcga:$(date +%Y%m%d)
  echo "Push completed."
else
  echo "Skipping push to Docker Hub."
fi

echo "\n=== Build Process Complete ===\n"
echo "Your image is now available locally as rrocap670/tcga:latest"
echo "Run it with: docker run -it rrocap670/tcga:latest"