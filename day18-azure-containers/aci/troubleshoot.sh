#!/bin/bash

# ==========================================
# Day 18 - ACI Troubleshooting
# ==========================================

set -e

RG="rg-day18-containers"
ACI="aci-nginx-custom"

echo "=========================================="
echo "Azure Container Instance Troubleshooting"
echo "=========================================="

# Verify Azure login
az account show > /dev/null

# Check whether ACI exists
if ! az container show 
    --resource-group "$RG" 
    --name "$ACI" > /dev/null 2>&1; then

    echo "ERROR: ACI does not exist in the resource group."
    exit 1
fi

# ------------------------------------------
# 1. Provisioning and Runtime State
# ------------------------------------------

echo ""
echo "========== ACI STATUS =========="

az container show 
    --resource-group "$RG" 
    --name "$ACI" 
    --query "{
        Name:name,
        ProvisioningState:provisioningState,
        RuntimeState:instanceView.state
    }" 
    -o json

# ------------------------------------------
# 2. Container Events
# ------------------------------------------

echo ""
echo "========== CONTAINER EVENTS =========="

az container show 
    --resource-group "$RG" 
    --name "$ACI" 
    --query "containers[].instanceView.events" 
    -o json

# ------------------------------------------
# 3. Container Logs
# ------------------------------------------

echo ""
echo "========== CONTAINER LOGS =========="

az container logs 
    --resource-group "$RG" 
    --name "$ACI" || true

# ------------------------------------------
# 4. Container Details
# ------------------------------------------

echo ""
echo "========== CONTAINER DETAILS =========="

az container show 
    --resource-group "$RG" 
    --name "$ACI" 
    --query "containers[].{
        Name:name,
        Image:properties.image,
        RestartCount:instanceView.restartCount,
        CurrentState:instanceView.currentState.state,
        PreviousState:instanceView.previousState.state
    }" 
    -o table

# ------------------------------------------
# 5. Public Endpoint
# ------------------------------------------

echo ""
echo "========== PUBLIC ENDPOINT =========="

az container show 
    --resource-group "$RG" 
    --name "$ACI" 
    --query "{
        IP:ipAddress.ip,
        FQDN:ipAddress.fqdn,
        Ports:ipAddress.ports
    }" 
    -o json

echo ""
echo "=========================================="
echo "Troubleshooting information collected!"
echo "=========================================="
