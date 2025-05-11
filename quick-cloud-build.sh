#!/bin/bash
# Quick Cloud Build Script
# Uses the specific cloud builder: cloud-rrocap670-tcga

set -e

echo "=== Building with Specific Cloud Builder ==="
echo "Builder: cloud-rrocap670-tcga"

# Step 1: Check if Docker is installed
if ! command -v docker &>/dev/null; then
  echo "Error: Docker not found. Please install Docker first."
  exit 1
fi

# Step 2: Get current directory for build context
BUILD_CONTEXT=$(pwd)
echo "Build context: $BUILD_CONTEXT"

# Step 3: Check if we're in the repository
if [ ! -f "./Dockerfile.fixed-v2" ] && [ ! -f "./Dockerfile.fixed" ] && [ ! -f "./Dockerfile" ]; then
  echo "Warning: No Dockerfile found in current directory."
  echo "  1. Clone repository: git clone https://github.com/RRocaP/uptospeed.git"
  echo "  2. Navigate to repository: cd uptospeed"
  echo "  3. Run this script again"
  
  read -p "Do you want to clone the repository now? (y/n): " clone_repo
  if [[ "$clone_repo" == "y" || "$clone_repo" == "Y" ]]; then
    if [ -d "uptospeed" ]; then
      cd uptospeed
    else
      git clone https://github.com/RRocaP/uptospeed.git
      cd uptospeed
    fi
    BUILD_CONTEXT=$(pwd)
    echo "New build context: $BUILD_CONTEXT"
  else
    echo "Continuing with current directory..."
  fi
fi

# Step 4: Check Docker Hub login
if ! docker info 2>/dev/null | grep -q "Username"; then
  echo "You are not logged in to Docker Hub. Please login:"
  docker login
fi

# Step 5: Create the cloud builder if it doesn't exist
if ! docker buildx ls | grep -q "cloud-rrocap670-tcga"; then
  echo "Cloud builder not found. Creating..."
  docker buildx create --driver cloud rrocap670/tcga || {
    echo "Failed to create cloud builder. This might be due to:"
    echo "1. Docker Desktop version (needs 4.25.0+ for cloud support)"
    echo "2. Docker subscription status"
    echo "3. Network connectivity to Docker Cloud"
    
    echo "Creating a local builder instead..."
    docker buildx create --name local-builder --driver docker-container
    docker buildx use local-builder --global
    BUILDER_NAME="local-builder"
  }
else
  echo "Cloud builder already exists."
  BUILDER_NAME="cloud-rrocap670-tcga"
fi

# Step 6: Set the builder as default
if [ "$BUILDER_NAME" == "cloud-rrocap670-tcga" ]; then
  echo "Setting cloud-rrocap670-tcga as default builder..."
  docker buildx use cloud-rrocap670-tcga --global
fi

# Step 7: Determine Dockerfile to use
if [ -f "./Dockerfile.fixed-v2" ]; then
  DOCKERFILE="Dockerfile.fixed-v2"
elif [ -f "./Dockerfile.fixed" ]; then
  DOCKERFILE="Dockerfile.fixed"
else
  DOCKERFILE="Dockerfile"
fi
echo "Using $DOCKERFILE for build..."

# Step 8: Build the image
echo "Building image with command:"
echo "docker buildx build --builder $BUILDER_NAME -t rrocap670/tcga:latest -f $DOCKERFILE ."

if [ "$BUILDER_NAME" == "cloud-rrocap670-tcga" ]; then
  # Using cloud builder
  docker buildx build --builder cloud-rrocap670-tcga -t rrocap670/tcga:latest -f $DOCKERFILE .
  
  # Ask if user wants to push
  read -p "Do you want to push the image to Docker Hub? (y/n): " push_image
  if [[ "$push_image" == "y" || "$push_image" == "Y" ]]; then
    echo "Pushing image to Docker Hub..."
    docker buildx build --builder cloud-rrocap670-tcga --push -t rrocap670/tcga:latest -f $DOCKERFILE .
  fi
else
  # Using local builder
  docker buildx build --builder $BUILDER_NAME --load -t rrocap670/tcga:latest -f $DOCKERFILE .
  
  # Ask if user wants to push
  read -p "Do you want to push the image to Docker Hub? (y/n): " push_image
  if [[ "$push_image" == "y" || "$push_image" == "Y" ]]; then
    echo "Pushing image to Docker Hub..."
    docker push rrocap670/tcga:latest
  fi
fi

echo "Build process complete!"
echo "You can run your image with: docker run -it rrocap670/tcga:latest"