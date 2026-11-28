#!/bin/bash

# ==========================================
# Day 18 - Push Custom NGINX Image to ACR
# ==========================================

set -e

RG="rg-day18-containers"
IMAGE="nginx-custom"
TAG="v1"

# Enter the ACR name created in create-acr.sh
ACR="${ACR:-}"

if [ -z "$ACR" ]; then
    read -r -p "Enter your ACR name: " ACR
fi

echo "=========================================="
echo "Pushing Custom Image to Azure ACR"
echo "=========================================="

# Verify Azure login
az account show > /dev/null

# Get ACR login server
LOGIN_SERVER=$(az acr show 
    --resource-group "$RG" 
    --name "$ACR" 
    --query loginServer 
    -o tsv)

if [ -z "$LOGIN_SERVER" ]; then
    echo "ERROR: Could not retrieve ACR login server."
    exit 1
fi

echo "Registry: $LOGIN_SERVER"

# Verify local image exists
docker image inspect "$IMAGE:$TAG" > /dev/null

# Authenticate with ACR
echo ""
echo "Authenticating with ACR..."

az acr login --name "$ACR"

# Tag image for ACR
echo ""
echo "Tagging Docker image..."

docker tag "$IMAGE:$TAG" "$LOGIN_SERVER/$IMAGE:$TAG"

# Push image
echo ""
echo "Pushing image to ACR..."

docker push "$LOGIN_SERVER/$IMAGE:$TAG"

echo ""
echo "=========================================="
echo "Image pushed successfully!"
echo "=========================================="
echo "Image: $LOGIN_SERVER/$IMAGE:$TAG"
