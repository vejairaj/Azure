#!/bin/bash

# ==========================================
# Day 18 - Build Custom NGINX Image
# ==========================================

set -e

IMAGE="nginx-custom"
TAG="v1"
PLATFORM="linux/amd64"

# Locate the Docker directory relative to this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKER_DIR="$SCRIPT_DIR/../docker"

echo "=========================================="
echo "Building Custom NGINX Docker Image"
echo "=========================================="

# Verify Dockerfile exists
if [ ! -f "$DOCKER_DIR/Dockerfile" ]; then
    echo "ERROR: Dockerfile not found!"
    exit 1
fi

# Build image
docker build 
    --platform "$PLATFORM" 
    -t "$IMAGE:$TAG" 
    "$DOCKER_DIR"

echo ""
echo "=========================================="
echo "Docker image built successfully!"
echo "=========================================="

# Display image details
docker images "$IMAGE:$TAG"
