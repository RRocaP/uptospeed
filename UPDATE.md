# How to Update Your Environment

This guide provides instructions for keeping your data science environment up to date.

## Updating the Base Setup

To update your base system setup:

1. Pull the latest changes from the repository:
   ```bash
   cd ~/uptospeed
   git pull
   ```

2. Run the setup script again:
   ```bash
   ./setup.sh
   ```

The script is designed to handle existing installations and will only update or install components as needed.

## Updating the Conda Environment

To update your data science conda environment:

1. Update conda itself:
   ```bash
   conda update -n base conda
   ```

2. Update all packages in the dsenv environment:
   ```bash
   conda activate dsenv
   conda update --all
   ```

3. To update to a new environment.yml (if available):
   ```bash
   conda env update -f environment.yml
   ```

## Adding New Packages

To add new packages to your environment:

1. Using conda:
   ```bash
   conda activate dsenv
   conda install -c conda-forge package-name
   ```

2. Using pip (within conda environment):
   ```bash
   conda activate dsenv
   pip install package-name
   ```

## Keeping Track of Your Environment

To save your current environment configuration:

```bash
conda activate dsenv
conda env export > my_environment.yml
```

This will create a YAML file with all your currently installed packages, which you can use to recreate the environment later or on another machine.