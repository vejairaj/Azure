#!/bin/bash

# ==========================================
# Day 18 - Azure Container Instances
# Deploy Custom NGINX from Private ACR
# Using User Assigned Managed Identity
# ==========================================

set -e

# ------------------------------------------
# Configuration
# ------------------------------------------

RG="rg-day18-containers"

IDENTITY="id-day18-acr-pull"

ACI="aci-nginx-custom"

IMAGE="nginx-custom"
TAG="v1"

CPU="1"
MEMORY="1.5"
PORT="80"

# Enter the ACR name created in the previous lab
ACR="${ACR:-}"

if [ -z "$ACR" ]; then
    read -r -p "Enter your ACR name: " ACR
fi

echo ""
echo "=========================================="
echo "Azure Container Instance Deployment"
echo "=========================================="

# ------------------------------------------
# Verify Azure login
# ------------------------------------------

az account show > /dev/null

# ------------------------------------------
# Retrieve ACR details
# ------------------------------------------

echo ""
echo "Retrieving ACR details..."

ACR_ID=$(az acr show 
    --resource-group "$RG" 
    --name "$ACR" 
    --query id 
    -o tsv)

LOGIN_SERVER=$(az acr show 
    --resource-group "$RG" 
    --name "$ACR" 
    --query loginServer 
    -o tsv)

# ------------------------------------------
# Retrieve Managed Identity details
# ------------------------------------------

echo ""
echo "Retrieving Managed Identity..."

IDENTITY_ID=$(az identity show 
    --resource-group "$RG" 
    --name "$IDENTITY" 
    --query id 
    -o tsv)

PRINCIPAL_ID=$(az identity show 
    --resource-group "$RG" 
    --name "$IDENTITY" 
    --query principalId 
    -o tsv)

# ------------------------------------------
# Assign AcrPull permission
# ------------------------------------------

echo ""
echo "Checking AcrPull permission..."

ROLE_EXISTS=$(az role assignment list 
    --scope "$ACR_ID" 
    --assignee "$PRINCIPAL_ID" 
    --query "[?roleDefinitionName=='AcrPull'] | length(@)" 
    -o tsv)

if [ "$ROLE_EXISTS" = "0" ]; then

    echo "Assigning AcrPull to Managed Identity..."

    az role assignment create \
        --assignee-object-id "$PRINCIPAL_ID" \
        --assignee-principal-type ServicePrincipal \
        --role AcrPull \
        --scope "$ACR_ID"

else

    echo "AcrPull permission already exists."

fi

# ------------------------------------------
# Verify image exists in ACR
# ------------------------------------------

echo ""
echo "Checking container image..."

az acr repository show-tags 
    --name "$ACR" 
    --repository "$IMAGE" 
    --query "[?@=='$TAG']" 
    -o tsv | grep -qx "$TAG"

echo "Image found: $LOGIN_SERVER/$IMAGE:$TAG"

# ------------------------------------------
# Check existing ACI
# ------------------------------------------

if az container show 
    --resource-group "$RG" 
    --name "$ACI" > /dev/null 2>&1; then

    echo "ERROR: ACI '$ACI' already exists."
    echo "Delete it or use another ACI name before continuing."
    exit 1

fi

# ------------------------------------------
# Generate unique DNS label
# ------------------------------------------

DNS_LABEL="aci-nginx-custom-$(date +%s)"

# ------------------------------------------
# Create Azure Container Instance
# ------------------------------------------

echo ""
echo "Creating Azure Container Instance..."

az container create 
    --resource-group "$RG" 
    --name "$ACI" 
    --image "$LOGIN_SERVER/$IMAGE:$TAG" 
    --os-type Linux 
    --cpu "$CPU" 
    --memory "$MEMORY" 
    --ports "$PORT" 
    --ip-address Public 
    --dns-name-label "$DNS_LABEL" 
    --restart-policy Always 
    --assign-identity "$IDENTITY_ID" 
    --acr-identity "$IDENTITY_ID"

# ------------------------------------------
# Display deployment details
# ------------------------------------------

echo ""
echo "=========================================="
echo "ACI deployment completed!"
echo "=========================================="

az container show 
    --resource-group "$RG" 
    --name "$ACI" 
    --query "{Name:name,State:instanceView.state,IP:ipAddress.ip,FQDN:ipAddress.fqdn}" 
    -o table

echo ""
echo "Open the ACI FQDN in your browser using HTTP."
echo "=========================================="
