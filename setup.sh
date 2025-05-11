#!/bin/bash
set -e

# Uptospeed - Data Science Environment Setup Script
# This script installs a comprehensive set of tools for data science and biological analysis

# Output color settings
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# Check if script is running as root and exit if it is
if [ "$(id -u)" -eq 0 ]; then
    error "This script should not be run as root"
fi

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
elif [ -f /etc/lsb-release ]; then
    . /etc/lsb-release
    OS=$DISTRIB_ID
elif [ "$(uname)" == "Darwin" ]; then
    OS="macOS"
else
    OS="Unknown"
fi

log "Detected OS: $OS"

# Create a folder for temporary downloads
mkdir -p ~/Downloads/uptospeed

# Function to install system packages
install_system_packages() {
    log "Installing system dependencies..."
    
    if [[ "$OS" == *"Ubuntu"* || "$OS" == *"Debian"* ]]; then
        sudo apt update
        sudo apt install -y build-essential wget curl git htop ncdu vim jq unzip zsh tree \
            python3-pip python3-dev libpq-dev libhdf5-dev libcurl4-openssl-dev \
            libssl-dev libffi-dev libxml2-dev libxslt1-dev libbz2-dev liblzma-dev
        success "System packages installed"
    elif [[ "$OS" == *"CentOS"* || "$OS" == *"RedHat"* || "$OS" == *"Fedora"* ]]; then
        sudo yum update -y
        sudo yum groupinstall -y "Development Tools"
        sudo yum install -y wget curl git htop ncdu vim jq unzip zsh tree \
            python3-pip python3-devel libpq-devel openssl-devel libffi-devel \
            libxml2-devel libxslt-devel bzip2-devel xz-devel
        success "System packages installed"
    elif [[ "$OS" == "macOS" ]]; then
        # Check if Homebrew is installed
        if ! command -v brew &> /dev/null; then
            log "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        
        brew update
        brew install wget curl git htop ncdu vim jq tree zsh
        success "System packages installed"
    else
        warn "Unsupported OS for automatic system package installation. Please install required packages manually."
    fi
}

# Install Miniforge
install_miniforge() {
    log "Installing Miniforge..."
    
    if [[ "$(uname)" == "Darwin" ]]; then
        if [[ "$(uname -m)" == "arm64" ]]; then
            # macOS ARM64 (Apple Silicon)
            MINIFORGE_URL="https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-MacOSX-arm64.sh"
        else
            # macOS x86_64
            MINIFORGE_URL="https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-MacOSX-x86_64.sh"
        fi
    else
        # Linux
        MINIFORGE_URL="https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-$(uname -m).sh"
    fi
    
    cd ~/Downloads/uptospeed
    wget -O miniforge.sh "$MINIFORGE_URL"
    chmod +x miniforge.sh
    
    # Install Miniforge
    bash miniforge.sh -b -p $HOME/miniforge3
    
    # Initialize conda
    $HOME/miniforge3/bin/conda init zsh
    $HOME/miniforge3/bin/conda init bash
    
    # Set up conda configuration
    $HOME/miniforge3/bin/conda config --set auto_activate_base false
    
    success "Miniforge installed"
}

# Install Oh My Zsh
install_omz() {
    log "Installing Oh My Zsh..."
    
    # Install Oh My Zsh
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        success "Oh My Zsh installed"
    else
        warn "Oh My Zsh is already installed"
    fi
    
    # Install useful plugins
    ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
    
    # Install zsh-autosuggestions
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    fi
    
    # Install zsh-syntax-highlighting
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    fi
    
    # Update .zshrc
    log "Configuring zsh..."
    
    # Backup existing .zshrc
    if [ -f "$HOME/.zshrc" ]; then
        cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    # Set up plugins and theme
    sed -i.bak 's/plugins=(git)/plugins=(git conda-zsh-completion pip python docker zsh-autosuggestions zsh-syntax-highlighting)/' "$HOME/.zshrc"
    success "Zsh configured with plugins"
}

# Install Aria2
install_aria2() {
    log "Installing Aria2..."
    
    if [[ "$OS" == *"Ubuntu"* || "$OS" == *"Debian"* ]]; then
        sudo apt install -y aria2
    elif [[ "$OS" == *"CentOS"* || "$OS" == *"RedHat"* || "$OS" == *"Fedora"* ]]; then
        sudo yum install -y aria2
    elif [[ "$OS" == "macOS" ]]; then
        brew install aria2
    else
        warn "Unsupported OS for automatic Aria2 installation. Please install manually."
    fi
    
    success "Aria2 installed"
}

# Create data science environment
create_ds_environment() {
    log "Creating data science conda environment..."
    
    # Create environment file
    cat > ~/Downloads/uptospeed/environment.yml << EOF
name: dsenv
channels:
  - conda-forge
  - bioconda
  - defaults
dependencies:
  - python=3.10
  - pip
  # Core data science
  - numpy
  - pandas
  - scipy
  - scikit-learn
  - scikit-image
  - statsmodels
  - xgboost
  - lightgbm
  - catboost
  # Deep learning
  - pytorch
  - torchvision
  - tensorflow
  - keras
  # Data visualization
  - matplotlib
  - seaborn
  - plotly
  - bokeh
  - altair
  - ipympl
  # Bioinformatics
  - biopython
  - bioservices
  - biotite
  - pysam
  - samtools
  - bcftools
  - bedtools
  - blast
  - hmmer
  - muscle
  # Interactive computing
  - jupyter
  - jupyterlab
  - notebook
  - ipywidgets
  # R and R packages
  - r-base
  - r-tidyverse
  - r-ggplot2
  - r-dplyr
  - r-biocmanager
  - r-devtools
  - rpy2
  - bioconductor-deseq2
  - bioconductor-edger
  # Image processing
  - opencv
  - pillow
  # File formats
  - h5py
  - netcdf4
  - xarray
  - pyarrow
  - fastparquet
  # Utilities
  - tqdm
  - click
  - pytest
  - black
  - isort
  - flake8
  - mypy
  - pip:
    - snakemake
    - wandb
    - mlflow
    - dvc
    - streamlit
    - dash
    - papermill
    - nbconvert
    - nbformat
    - scanpy
    - anndata
    - squidpy
    - cellrank
EOF
    
    # Create the environment
    $HOME/miniforge3/bin/conda env create -f ~/Downloads/uptospeed/environment.yml
    
    success "Data science environment created"
}

# Set up CUDA (if available)
setup_cuda() {
    log "Setting up CUDA..."
    
    # Check if NVIDIA GPU is available
    if command -v nvidia-smi &> /dev/null; then
        log "NVIDIA GPU detected. Installing CUDA dependencies..."
        
        if [[ "$OS" == *"Ubuntu"* || "$OS" == *"Debian"* ]]; then
            # Install CUDA toolkit
            log "Adding NVIDIA repository..."
            
            # Get Ubuntu version
            UBUNTU_VERSION=$(lsb_release -rs | sed 's/\.//')
            
            wget -O /tmp/cuda-keyring.deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu${UBUNTU_VERSION}/x86_64/cuda-keyring_1.0-1_all.deb
            sudo dpkg -i /tmp/cuda-keyring.deb
            sudo apt-get update
            sudo apt-get install -y cuda-toolkit-12-0
            
            # Add CUDA to path in .zshrc and .bashrc
            echo 'export PATH="/usr/local/cuda/bin:$PATH"' >> $HOME/.zshrc
            echo 'export LD_LIBRARY_PATH="/usr/local/cuda/lib64:$LD_LIBRARY_PATH"' >> $HOME/.zshrc
            echo 'export PATH="/usr/local/cuda/bin:$PATH"' >> $HOME/.bashrc
            echo 'export LD_LIBRARY_PATH="/usr/local/cuda/lib64:$LD_LIBRARY_PATH"' >> $HOME/.bashrc
            
            success "CUDA toolkit installed"
        else
            warn "Automatic CUDA installation only supported for Ubuntu. Please install CUDA manually for your OS."
        fi
    else
        warn "No NVIDIA GPU detected. Skipping CUDA installation."
    fi
}

# Create useful aliases and configurations
create_configs() {
    log "Creating useful configurations..."
    
    # Create a .aliases file
    cat > $HOME/.aliases << EOF
# General aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias df='df -h'
alias du='du -h'
alias free='free -h'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'

# Python/Conda aliases
alias ca='conda activate'
alias cda='conda deactivate'
alias cel='conda env list'
alias jlab='jupyter lab'
alias jnb='jupyter notebook'

# Useful data science shortcuts
alias nv='nvidia-smi'
alias nv-watch='watch -n1 nvidia-smi'

# Directory navigation
alias ds='cd ~/data-science'
alias papers='cd ~/papers'
alias projects='cd ~/projects'
EOF
    
    # Source the aliases file in .zshrc and .bashrc
    echo 'source $HOME/.aliases' >> $HOME/.zshrc
    echo 'source $HOME/.aliases' >> $HOME/.bashrc
    
    # Create useful directories
    mkdir -p $HOME/data-science
    mkdir -p $HOME/projects
    mkdir -p $HOME/papers
    mkdir -p $HOME/datasets
    
    success "Configurations created"
}

# Main execution
main() {
    log "Starting Uptospeed data science environment setup..."
    
    # Run installation steps
    install_system_packages
    install_miniforge
    install_omz
    install_aria2
    create_ds_environment
    setup_cuda
    create_configs
    
    success "Setup completed! Please restart your terminal or run 'source ~/.zshrc' to apply changes."
    log "Your data science environment is ready. Activate it with 'conda activate dsenv'"
}

# Run the main function
main