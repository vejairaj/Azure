#!/bin/bash

# ==========================================
# Day 18 - Azure Container Registry
# Create a new ACR
# ==========================================

set -e

# Resource Group
RG="rg-day18-containers"

# Generate a unique ACR name
ACR="acrday18$(date +%s)"

echo "Creating Azure Container Registry..."
echo "Resource Group: $RG"
echo "ACR Name: $ACR"

# Check Azure login
az account show > /dev/null

# Create ACR
az acr create 
    --resource-group "$RG" 
    --name "$ACR" 
    --sku Basic 
    --admin-enabled false

# Retrieve login server
LOGIN_SERVER=$(az acr show 
    --resource-group "$RG" 
    --name "$ACR" 
    --query loginServer 
    -o tsv)

echo ""
echo "=========================================="
echo "ACR created successfully!"
echo "=========================================="
echo "Resource Group : $RG"
echo "Registry Name  : $ACR"
echo "Login Server   : $LOGIN_SERVER"
echo ""
echo "Save these values for the next lab steps."

