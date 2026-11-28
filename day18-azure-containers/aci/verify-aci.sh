#!/bin/bash

# ==========================================
# Day 18 - Verify Azure Container Instance
# ==========================================

set -e

RG="rg-day18-containers"
ACI="aci-nginx-custom"

echo "=========================================="
echo "Azure Container Instance Verification"
echo "=========================================="

# Verify Azure login
az account show > /dev/null

# Check ACI exists
if ! az container show 
    --resource-group "$RG" 
    --name "$ACI" > /dev/null 2>&1; then

    echo "ERROR: ACI does not exist."
    exit 1
fi

# ------------------------------------------
# Provisioning and runtime details
# ------------------------------------------

echo ""
echo "ACI Details:"

az container show 
    --resource-group "$RG" 
    --name "$ACI" 
    --query "{
        Name:name,
        ProvisioningState:provisioningState,
        State:instanceView.state,
        IP:ipAddress.ip,
        FQDN:ipAddress.fqdn
    }" 
    -o table

# ------------------------------------------
# Container details
# ------------------------------------------

echo ""
echo "Container Details:"

az container show 
    --resource-group "$RG" 
    --name "$ACI" 
    --query "containers[].{
        Name:name,
        Image:properties.image,
        CPU:resources.requests.cpu,
        Memory:resources.requests.memoryInGB,
        RestartCount:instanceView.restartCount,
        State:instanceView.currentState.state
    }" 
    -o table

# ------------------------------------------
# Retrieve public FQDN
# ------------------------------------------

FQDN=$(az container show 
    --resource-group "$RG" 
    --name "$ACI" 
    --query ipAddress.fqdn 
    -o tsv)

if [ -z "$FQDN" ] || [ "$FQDN" = "None" ]; then
    echo ""
    echo "WARNING: Public FQDN is not available yet."
    exit 1
fi

# ------------------------------------------
# Check HTTP response
# ------------------------------------------

echo ""
echo "Checking application HTTP response..."

if command -v curl > /dev/null 2>&1; then

    curl -sS --max-time 15 \
        -o /dev/null \
        -w "HTTP Status: %{http_code}\n" \
        "http://$FQDN"

else

    echo "curl is not installed. Open this URL in your browser:"
    echo "http://$FQDN"

fi

echo ""
echo "=========================================="
echo "ACI verification completed!"
echo "=========================================="

echo "Application URL: http://$FQDN"
