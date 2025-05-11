# Optimizing Docker Builds for R and Python Data Science Containers

## Strategy 1: Use a prebuilt R image as base

```dockerfile
# Instead of:
FROM continuumio/miniconda3:latest

# Use:
FROM rocker/tidyverse:latest

WORKDIR /app

# Install miniconda
RUN apt-get update && apt-get install -y wget && \
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -p /opt/conda && \
    rm /tmp/miniconda.sh

# Add conda to path
ENV PATH="/opt/conda/bin:${PATH}"

# Create Python environment
RUN conda create -n hcc-pipeline python=3.9 -y
```

## Strategy 2: Multi-stage build

```dockerfile
# R packages stage
FROM rocker/r-ver:4.3 as r-base
RUN R -e "install.packages(c('BiocManager', 'argparse', 'data.table', 'tidyverse', 'R.utils'), repos='https://cloud.r-project.org/')"
RUN R -e "BiocManager::install(c('GenomicRanges', 'rtracklayer', 'Rsamtools'))"

# Python stage
FROM continuumio/miniconda3:latest as python-base
RUN conda create -n hcc-pipeline python=3.9 -y
RUN echo "source activate hcc-pipeline" > ~/.bashrc
# Install Python dependencies
COPY environment.yml .
RUN conda env update -n hcc-pipeline -f environment.yml

# Final stage
FROM continuumio/miniconda3:latest
WORKDIR /app
# Install essential system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential curl libcurl4-openssl-dev libxml2-dev \
    libssl-dev libfontconfig1-dev libharfbuzz-dev libfribidi-dev \
    libfreetype6-dev libpng-dev libtiff5-dev libjpeg-dev r-base

# Copy R libraries from r-base
COPY --from=r-base /usr/local/lib/R/site-library /usr/local/lib/R/site-library

# Copy Python environment from python-base
COPY --from=python-base /opt/conda /opt/conda
ENV PATH="/opt/conda/bin:${PATH}"
RUN echo "source activate hcc-pipeline" > ~/.bashrc

# Copy your application
COPY . .

# Set the entry point
ENTRYPOINT ["conda", "run", "--no-capture-output", "-n", "hcc-pipeline", "python", "your_script.py"]
```

## Strategy 3: Use Docker layer caching effectively

1. Split the R installation into multiple steps, with most frequently changing packages last:

```dockerfile
# Base R packages first
RUN R -e "install.packages(c('BiocManager', 'argparse', 'data.table', 'R.utils'), repos='https://cloud.r-project.org/')"

# Tidyverse (large but stable) next
RUN R -e "install.packages('tidyverse', repos='https://cloud.r-project.org/')"

# Bioconductor packages last (if these change frequently)
RUN R -e "BiocManager::install(c('GenomicRanges', 'rtracklayer', 'Rsamtools'))"
```

## Strategy 4: Use a CRAN mirror closer to your build location

```dockerfile
# Specify a faster CRAN mirror
RUN R -e "install.packages(c('BiocManager', 'argparse', 'data.table', 'tidyverse', 'R.utils'), repos='https://packagemanager.posit.co/cran/__linux__/focal/latest')"
```

## Strategy 5: Install binary packages instead of building from source

```dockerfile
# For Ubuntu-based containers
RUN apt-get update && apt-get install -y --no-install-recommends \
    r-cran-tidyverse \
    r-cran-data.table \
    r-cran-r.utils \
    r-cran-argparse
```

## Strategy 6: Use package caching with volumes

```bash
# Create a Docker volume for R packages
docker volume create r-pkg-cache

# Use the volume when building
docker build --build-arg CRAN_MIRROR=https://cloud.r-project.org/ \
             --mount=type=volume,target=/usr/local/lib/R/site-library,source=r-pkg-cache \
             -t hcc-pipeline .
```

## Strategy 7: Use BuildKit cache mounts

```dockerfile
# In your Dockerfile (requires BuildKit)
# syntax=docker/dockerfile:1.4
FROM continuumio/miniconda3:latest
WORKDIR /app

RUN --mount=type=cache,target=/var/cache/apt \
    apt-get update && apt-get install -y --no-install-recommends \
    build-essential curl libcurl4-openssl-dev libxml2-dev \
    libssl-dev libfontconfig1-dev libharfbuzz-dev libfribidi-dev \
    libfreetype6-dev libpng-dev libtiff5-dev libjpeg-dev r-base

RUN --mount=type=cache,target=/root/.cache/R \
    R -e "install.packages(c('BiocManager', 'argparse', 'data.table', 'tidyverse', 'R.utils'), repos='https://cloud.r-project.org/')"
```

Build with:
```bash
DOCKER_BUILDKIT=1 docker build -t hcc-pipeline .
```

## Strategy 8: Use parallel installation for R packages

```dockerfile
RUN R -e "install.packages('parallel')" && \
    R -e "parallel::mclapply(c('BiocManager', 'argparse', 'data.table', 'tidyverse', 'R.utils'), function(pkg) install.packages(pkg, repos='https://cloud.r-project.org/'), mc.cores = parallel::detectCores())"
```

## Strategy 9: Create a custom base image and push to Docker Hub

Create a base image with all dependencies and push it to Docker Hub. Then use this as your base image for future builds.

```bash
# Build the base image
docker build -t yourusername/hcc-pipeline-base:latest -f Dockerfile.base .

# Push it to Docker Hub
docker push yourusername/hcc-pipeline-base:latest

# Use it in your main Dockerfile
FROM yourusername/hcc-pipeline-base:latest
# Just add your code, no need to reinstall packages
COPY . .
```

## Practical Implementation

For your specific case, I recommend:

1. Create a `Dockerfile.base` with all R and Python dependencies
2. Push this to Docker Hub
3. Use that image as the base for your actual application
4. Implement BuildKit cache mounts for package installation

This approach separates dependency installation (slow, infrequent) from application code updates (fast, frequent), dramatically improving build times.