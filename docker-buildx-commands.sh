#!/bin/bash
# Docker Buildx Commands Reference

# Check buildx version
echo "Checking buildx version..."
docker buildx version

# List existing builders
echo "Listing existing builders..."
docker buildx ls

# Create a cloud builder (correct syntax)
echo "Creating cloud builder example command:"
echo "docker buildx create --driver cloud rrocap670/tcga2"
echo "# Note: No dot/period at the end, no additional arguments"

# Create a remote builder (alternative)
echo "Creating remote builder example command:"
echo "docker buildx create --name remote-builder --driver remote tcp://localhost:1234"

# Use a specific builder
echo "Setting a builder as default:"
echo "docker buildx use <builder-name>"

# Build with a specific builder
echo "Building with a specific builder:"
echo "docker buildx build --builder <builder-name> -t image:tag ."

# Build and push example
echo "Building and pushing to registry:"
echo "docker buildx build --builder <builder-name> --platform linux/amd64,linux/arm64 --push -t username/image:tag ."

# Working with the default builder
echo "Building with default builder:"
echo "docker buildx build -t image:tag ."

# Delete a builder
echo "Deleting a builder:"
echo "docker buildx rm <builder-name>"

# Common errors and fixes
echo ""
echo "Common errors and fixes:"
echo "1. 'cloud driver not found' - Install latest docker-buildx-plugin"
echo "2. 'permission denied' - Run 'sudo usermod -aG docker $USER' and log out/in"
echo "3. 'driver not installed' - Ensure docker engine is up to date"
echo "4. 'unknown flag' - Check command syntax, flags like --driver should be before arguments"