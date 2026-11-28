#!/bin/bash

# ==========================================
# Day 18 - ACI Cleanup
# Delete Container Instance only
# ==========================================

set -e

RG="rg-day18-containers"
ACI="aci-nginx-custom"

echo "=========================================="
echo "Azure Container Instance Cleanup"
echo "=========================================="

# Verify Azure login
az account show > /dev/null

# Check whether ACI exists
if ! az container show 
    --resource-group "$RG" 
    --name "$ACI" > /dev/null 2>&1; then

    echo "ACI '$ACI' does not exist."
    exit 0
fi

echo ""
echo "The following resource will be deleted:"
echo "Resource Group : $RG"
echo "Container Name : $ACI"

echo ""
echo "ACR and Managed Identity will NOT be deleted."

read -r -p "Are you sure you want to delete this ACI? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "Cleanup cancelled."
    exit 0
fi

# Delete ACI
echo ""
echo "Deleting Azure Container Instance..."

az container delete 
    --resource-group "$RG" 
    --name "$ACI" 
    --yes

echo ""
echo "=========================================="
echo "ACI deletion requested successfully!"
echo "=========================================="

echo "Retained resources:"
echo "- Azure Container Registry"
echo "- User Assigned Managed Identity"
echo "- Resource Group"
