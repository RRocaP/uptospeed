#!/bin/bash
# Mac Setup Script for Uptospeed
# This script sets up the repository and tools on macOS

set -e  # Exit on error

echo "=== Uptospeed Mac Setup ==="
echo "This script will clone the repository and set up your Mac"
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

# Step 7: Create a BuildKit builder (Mac-specific approach)
echo "Step 7: Setting up Docker BuildKit..."
if ! docker buildx ls | grep -q "mac-builder"; then
  echo "Creating BuildKit builder..."
  docker buildx create --name mac-builder --driver docker-container
  docker buildx use mac-builder
  docker buildx inspect --bootstrap
else
  echo "BuildKit builder already exists."
  docker buildx use mac-builder
fi

# Step 8: Get Docker Hub credentials
echo -e "\nStep 8: Checking Docker Hub login..."
if ! docker info 2>/dev/null | grep -q "Username"; then
  echo "You are not logged in to Docker Hub. Please login:"
  docker login
else
  echo "Already logged in to Docker Hub."
fi

# Step 9: Create Mac-specific scripts
echo "Step 9: Creating Mac-specific scripts..."

# Create a build script for Mac
cat > ./mac-build.sh << 'EOF'
#!/bin/bash
# Mac Build Script for Uptospeed

set -e

echo "=== Building with Docker BuildKit on Mac ==="

# Ensure BuildKit is enabled
export DOCKER_BUILDKIT=1

# Use the mac-builder
docker buildx use mac-builder

# Build the image
echo "Building the Docker image..."
docker buildx build --load -t rrocap670/tcga:latest -f Dockerfile.fixed-v2 .

echo "Build complete! Your image is now available as rrocap670/tcga:latest"
echo "Run it with: docker run -it rrocap670/tcga:latest"
echo
echo "To push to Docker Hub: docker push rrocap670/tcga:latest"
EOF

chmod +x ./mac-build.sh

# Step 10: Suggest next steps
echo -e "\n=== Setup Complete ==="
echo "Your Mac environment is now ready! You can run the following commands:"
echo
echo "1. To build the Docker image:"
echo "   ./mac-build.sh"
echo
echo "2. To run the setup script (install R, Python, etc.):"
echo "   ./setup.sh"
echo
echo "All files are located in: $(pwd)"
echo
echo "To quickly clone this repository on another Mac, run:"
echo "curl -fsSL https://raw.githubusercontent.com/RRocaP/uptospeed/main/mac-setup.sh | bash"

# Return to the repository root
cd ~/projects/uptospeed