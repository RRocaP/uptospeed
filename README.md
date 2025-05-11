# Uptospeed

A set of scripts to quickly set up a complete data science environment on any machine.

## Features

- 🐍 **Miniforge**: Conda distribution with conda-forge as default channel
- 🧪 **Data Science Environment**: Ready-to-use environment with Python, R, and essential libraries
- 🧠 **Machine Learning**: PyTorch, TensorFlow, and common ML libraries
- 🧬 **Bioinformatics**: Biopython, Bioconductor, and common bio tools
- 📊 **Visualization**: Matplotlib, Seaborn, ggplot2, and interactive viz libraries
- 🖥️ **CUDA**: Automatic NVIDIA GPU detection and setup (when available)
- 🔄 **Aria2**: High-speed download utility
- 🐚 **ZSH + Oh My Zsh**: Enhanced shell with useful plugins
- ⚡ **Productivity**: Useful aliases and configurations

## Quick Start

```bash
# Clone the repository
git clone https://github.com/RRocaP/uptospeed.git
cd uptospeed

# Make the script executable
chmod +x setup.sh

# Run the setup script
./setup.sh
```

## What's Included

### Core Components

- **Miniforge**: A minimal conda installer with conda-forge packages
- **Oh My Zsh**: Framework for managing Zsh configuration with plugins
- **Aria2**: High-speed download utility
- **CUDA**: NVIDIA GPU support (when hardware is available)

### Data Science Environment

The script creates a conda environment named `dsenv` with:

#### Python Libraries
- **Data Analysis**: NumPy, Pandas, SciPy, Scikit-learn
- **Machine Learning**: PyTorch, TensorFlow, XGBoost, LightGBM
- **Visualization**: Matplotlib, Seaborn, Plotly, Altair

#### R Packages
- **Base**: R with essential packages
- **Tidyverse**: Data manipulation and visualization
- **Bioconductor**: Bioinformatics tools

#### Bioinformatics
- Biopython, BioServices, Pysam
- Samtools, BCFtools, Bedtools
- BLAST, HMMER, MUSCLE

#### Development Tools
- Jupyter Lab & Notebook
- Testing and linting tools
- Version control utilities

## Customization

The environment can be customized by editing the `environment.yml` file that's generated during setup. After making changes, update your environment with:

```bash
conda env update -f environment.yml
```

## Supported Operating Systems

- Ubuntu/Debian-based distributions
- CentOS/RedHat/Fedora
- macOS (with Homebrew)

## License

MIT