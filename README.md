# Uptospeed

A set of scripts to quickly set up a complete data science environment on any machine.

## Features

- 🐍 **Miniforge**: Conda distribution with conda-forge as default channel
- 🧪 **Data Science Environment**: Ready-to-use environment with Python, R, and essential libraries
- 🧠 **Machine Learning**: PyTorch, TensorFlow, and common ML libraries
- 🧬 **Bioinformatics**: Biopython, Bioconductor, and common bio tools
- 📊 **Visualization**: Matplotlib, Seaborn, ggplot2, and interactive viz libraries
- 🐳 **Docker Images**: Pre-configured data science containers (Rocker/Tidyverse, Jupyter, TensorFlow, PyTorch)
- 🖥️ **CUDA**: Automatic NVIDIA GPU detection and setup (when available)
- 💻 **VS Code**: Installation with data science extensions
- 🤖 **AI Coding Tools**: Claude Code and Open Codex
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
- **Docker**: Container platform with pre-pulled data science images
- **VS Code**: Code editor with data science extensions
- **Oh My Zsh**: Framework for managing Zsh configuration with plugins
- **Aria2**: High-speed download utility
- **CUDA**: NVIDIA GPU support (when hardware is available)

### Docker Images

The script pulls and configures convenient shortcuts for these Docker images:

- **rocker/tidyverse**: R with Tidyverse packages and RStudio Server
- **jupyter/datascience-notebook**: Jupyter with Python, R, and Julia
- **tensorflow/tensorflow**: TensorFlow with GPU support and Jupyter
- **pytorch/pytorch**: PyTorch with GPU support

Run them with simple aliases:
- `r-studio`: Launches RStudio Server with Tidyverse
- `ds-jupyter`: Launches Jupyter Data Science Notebook
- `tf-jupyter`: Launches TensorFlow with Jupyter
- `pt-jupyter`: Launches PyTorch with Jupyter

### AI Coding Tools

- **Claude Code**: Anthropic's CLI for Claude
- **Open Codex**: Gemini AI assistant (configured with Gemini 2.5 Pro)

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