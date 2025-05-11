#!/bin/bash
# Mac Cloud Builder Setup Script for Uptospeed
# This script sets up the repository and cloud builder on macOS

set -e  # Exit on error

echo "=== Uptospeed Mac Cloud Builder Setup ==="
echo "This script will clone the repository and set up Docker Cloud Builder"
echo

# Step 1: Check if Homebrew is installed
echo "Step 1: Checking for Homebrew..."
if ! command -v brew &>/dev/null; then
  echo "Homebrew not found. Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  
  # Add Homebrew to PATH for the current session
  if [[ $(uname -m) == 'arm64' ]]; then
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> $HOME/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    echo 'eval "$(/usr/local/bin/brew shellenv)"' >> $HOME/.zprofile
    eval "$(/usr/local/bin/brew shellenv)"
  fi
else
  echo "Homebrew is already installed."
fi

# Step 2: Install basic dependencies
echo "Step 2: Installing basic dependencies..."
brew install git curl wget

# Step 3: Create project directory
echo "Step 3: Creating project directory..."
mkdir -p ~/projects
cd ~/projects

# Step 4: Clone the repository
echo "Step 4: Cloning the repository..."
if [ -d "uptospeed" ]; then
  echo "Directory already exists. Pulling latest changes..."
  cd uptospeed
  git pull
else
  git clone https://github.com/RRocaP/uptospeed.git
  cd uptospeed
fi

# Step 5: Make scripts executable
echo "Step 5: Making scripts executable..."
find . -name "*.sh" -exec chmod +x {} \;

# Step 6: Check for Docker Desktop
echo "Step 6: Checking for Docker Desktop..."
if ! command -v docker &>/dev/null; then
  echo "Docker not found. Please install Docker Desktop for Mac:"
  echo "Visit: https://www.docker.com/products/docker-desktop/"
  echo "After installation, run this script again."
  open "https://www.docker.com/products/docker-desktop/"
  exit 1
else
  echo "Docker Desktop is installed."
  docker --version
  docker buildx version
fi

# Step 7: Get Docker Hub credentials
echo -e "\nStep 7: Checking Docker Hub login..."
if ! docker info 2>/dev/null | grep -q "Username"; then
  echo "You are not logged in to Docker Hub. Please login:"
  docker login
else
  echo "Already logged in to Docker Hub."
fi

# Step 8: Set up Docker Cloud Builder
echo "Step 8: Setting up Docker Cloud Builder..."
DOCKER_USERNAME=$(docker info 2>/dev/null | grep Username | awk '{print $2}')
if [ -z "$DOCKER_USERNAME" ]; then
  echo "Could not determine Docker username. Please enter your Docker Hub username:"
  read -p "> " DOCKER_USERNAME
fi

echo "Creating Cloud Builder for user: $DOCKER_USERNAME"

# Remove existing builder if it exists
docker buildx rm cloud-${DOCKER_USERNAME}-tcga 2>/dev/null || true

# Create the cloud builder
if docker buildx create --driver cloud ${DOCKER_USERNAME}/tcga; then
  echo "Cloud builder created successfully!"
  docker buildx use cloud-${DOCKER_USERNAME}-tcga --global
else
  echo "Failed to create cloud builder. Setting up an alternative builder..."
  docker buildx create --name mac-builder --driver docker-container
  docker buildx use mac-builder --global
  echo "Alternative builder 'mac-builder' created and set as default."
fi

# Step 9: Create Mac-specific cloud build script
echo "Step 9: Creating Mac cloud build script..."

# Create a cloud build script for Mac
cat > ./mac-cloud-build.sh << EOF
#!/bin/bash
# Mac Cloud Build Script for Uptospeed

set -e

echo "=== Building with Docker Cloud Builder ==="

# Check which builder we're using
CURRENT_BUILDER=\$(docker buildx ls | grep "\*" | awk '{print \$1}')
echo "Using builder: \$CURRENT_BUILDER"

# Build the image
echo "Building the Docker image..."
if [[ \$CURRENT_BUILDER == cloud-* ]]; then
  echo "Building with Cloud Builder..."
  docker buildx build --push -t ${DOCKER_USERNAME}/tcga:latest -f Dockerfile.fixed-v2 .
  echo "Build complete and pushed to Docker Hub as ${DOCKER_USERNAME}/tcga:latest"
else
  echo "Building with local BuildKit..."
  docker buildx build --load -t ${DOCKER_USERNAME}/tcga:latest -f Dockerfile.fixed-v2 .
  echo "Build complete! Image is available locally as ${DOCKER_USERNAME}/tcga:latest"
  echo "To push to Docker Hub, run: docker push ${DOCKER_USERNAME}/tcga:latest"
fi

echo "Run the image with: docker run -it ${DOCKER_USERNAME}/tcga:latest"
EOF

chmod +x ./mac-cloud-build.sh

# Step 10: Suggest next steps
echo -e "\n=== Setup Complete ==="
echo "Your Mac environment is now ready! You can run the following commands:"
echo
echo "1. To build with cloud builder:"
echo "   ./mac-cloud-build.sh"
echo
echo "2. To run the setup script (install R, Python, etc.):"
echo "   ./setup.sh"
echo
echo "All files are located in: $(pwd)"
echo
echo "To quickly clone this repository on another Mac, run:"
echo "curl -fsSL https://raw.githubusercontent.com/RRocaP/uptospeed/main/mac-cloud-setup.sh | bash"

# Return to the repository root
cd ~/projects/uptospeed