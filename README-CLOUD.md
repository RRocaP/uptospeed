# Uptospeed Cloud Machine Setup

This guide explains how to quickly set up a new cloud machine with the Uptospeed repository and all necessary tools.

## One-Command Setup

To set up a new cloud machine with a single command, run:

```bash
curl -fsSL https://raw.githubusercontent.com/RRocaP/uptospeed/main/cloud-machine-setup.sh | bash
```

This command will:
1. Clone the repository
2. Install Docker (if not already installed)
3. Set up Docker BuildKit
4. Configure the firewall for Docker Cloud
5. Test Docker Cloud connectivity
6. Prompt for Docker Hub login if needed

## Manual Setup

If you prefer a manual approach:

1. **Clone the repository:**
   ```bash
   git clone https://github.com/RRocaP/uptospeed.git
   cd uptospeed
   ```

2. **Make scripts executable:**
   ```bash
   find . -name "*.sh" -exec chmod +x {} \;
   ```

3. **Fix Docker installation (if needed):**
   ```bash
   ./fix-docker-install.sh
   ```

4. **Set up BuildKit:**
   ```bash
   ./docker-buildkit-workaround.sh
   ```

5. **Configure firewall for Docker Cloud:**
   ```bash
   sudo ./docker-cloud-firewall.sh
   ```

6. **Test Docker Cloud connectivity:**
   ```bash
   ./docker-cloud-access-test.sh
   ```

## Building Docker Images

### Using Local BuildKit

```bash
./use-regular-docker.sh
```

### Using Docker Cloud (if configured)

```bash
docker buildx create --driver cloud yourusername/buildername
docker buildx build --builder cloud-yourusername-buildername -t yourusername/tcga:latest .
```

## Available Scripts

- `setup.sh` - Main environment setup script (R, Python, etc.)
- `fix-docker-install.sh` - Fix Docker installation issues
- `docker-buildkit-workaround.sh` - Set up BuildKit without cloud driver
- `docker-cloud-firewall.sh` - Configure firewall for Docker Cloud
- `docker-cloud-access-test.sh` - Test Docker Cloud connectivity
- `use-regular-docker.sh` - Build with standard Docker + BuildKit
- `docker-buildx-commands.sh` - Reference for BuildX commands

## Dockerfile Versions

- `Dockerfile.fixed-v2` - Latest optimized Dockerfile with error handling
- `Dockerfile.fixed` - Optimized Dockerfile
- `Dockerfile.example` - Example Dockerfile with BuildKit optimizations