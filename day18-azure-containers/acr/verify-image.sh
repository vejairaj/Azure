#!/bin/bash

# ==========================================
# Day 18 - Verify Image in Azure ACR
# ==========================================

set -e

RG="rg-day18-containers"
IMAGE="nginx-custom"
TAG="v1"

# Enter the ACR name created earlier
ACR="${ACR:-}"

if [ -z "$ACR" ]; then
    read -r -p "Enter your ACR name: " ACR
fi

echo "=========================================="
echo "Verifying Azure Container Registry"
echo "=========================================="

# Verify Azure login
az account show > /dev/null

# Verify ACR exists
az acr show 
    --resource-group "$RG" 
    --name "$ACR" 
    --query "{Name:name,LoginServer:loginServer,SKU:sku.name}" 
    -o table

echo ""
echo "Available repositories:"

# List repositories
az acr repository list 
    --name "$ACR" 
    -o table

echo ""
echo "Available image tags:"

# List tags
az acr repository show-tags 
    --name "$ACR" 
    --repository "$IMAGE" 
    -o table

echo ""
echo "Checking image manifest..."

# Verify image manifest
az acr manifest show-metadata 
    --registry "$ACR" 
    --name "$IMAGE:$TAG" 
    --query "{Image:name,Digest:digest,Created:createdTime}" 
    -o table

echo ""
echo "=========================================="
echo "ACR image verification completed!"
echo "=========================================="
