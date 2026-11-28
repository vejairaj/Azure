# Day 18 – Azure Container Registry (ACR) & Azure Container Instances (ACI)

## Overview

In this lab, I worked with Azure Container Registry and Azure Container Instances to understand how container images are stored, authenticated and deployed in Azure.

I created a custom NGINX Docker image locally, pushed it to a new Azure Container Registry, and deployed it using Azure Container Instances.

I also reused a User Assigned Managed Identity to authenticate ACI with the private ACR without storing registry credentials.

## Architecture

```text
                  My Mac
                    |
                    | Docker build
                    v
              nginx-custom:v1
                    |
                    | Docker push
                    v
          Azure Container Registry
                    |
                    | AcrPull permission
                    |
          User Assigned Managed
                 Identity
                    |
                    | Authentication
                    v
         Azure Container Instances
                    |
                    v
              NGINX Container
                    |
                    v
              HTTP - Port 80
```

## Azure Resources

| Resource | Configuration |
|---|---|
| Resource Group | rg-day18-containers |
| Container Registry | New ACR |
| Registry SKU | Basic |
| Repository | nginx-custom |
| Image Tag | v1 |
| Managed Identity | id-day18-acr-pull |
| ACI | aci-nginx-custom |
| Operating System | Linux |
| CPU | 1 |
| Memory | 1.5 GB |
| Container Port | 80 |
| IP Address | Public |

## Lab 1 – Azure Container Registry

### 1. Create a new ACR

Created a new Azure Container Registry using the Basic SKU.

### 2. Build the Docker image

Built the custom NGINX image locally using Docker.

```bash
docker build --platform linux/amd64 -t nginx-custom:v1 .
```

### 3. Authenticate with ACR

```bash
az acr login --name $ACR
```

### 4. Tag the image

```bash
docker tag nginx-custom:v1 \
  $LOGIN_SERVER/nginx-custom:v1
```

### 5. Push the image

```bash
docker push $LOGIN_SERVER/nginx-custom:v1
```

### 6. Verify the image

```bash
az acr repository list --name $ACR -o table
```

```bash
az acr repository show-tags \
  --name $ACR \
  --repository nginx-custom \
  -o table
```

## Lab 2 – Azure Container Instances

### 1. Managed Identity

Reused the existing User Assigned Managed Identity:

`id-day18-acr-pull`

### 2. Assign AcrPull permission

Assigned the AcrPull role to the managed identity at the scope of the newly created ACR.

This permission allows the identity to pull images from that registry.

**Important:** Role assignments are scoped to Azure resources. Having AcrPull on an existing registry does not automatically grant access to a newly created registry.

### 3. Deploy ACI

Deployed the custom NGINX image using Azure Container Instances.

Configuration:

- Linux container
- 1 vCPU
- 1.5 GB memory
- Public IP address
- HTTP port 80
- User Assigned Managed Identity
- Private image from ACR

### 4. Verify deployment

Verified the container state, retrieved the public FQDN and checked the application through a web browser.

The NGINX application loaded successfully.

## Authentication Flow

When ACI starts, it uses the configured User Assigned Managed Identity to authenticate with Azure Container Registry.

ACR checks the identity's role assignments.

If the identity has the required AcrPull permission, ACR allows the image to be downloaded.

ACI then starts the container using the downloaded image.

```text
ACI
 |
 v
User Assigned Managed Identity
 |
 v
Microsoft Entra ID
 |
 v
ACR authorization check
 |
 v
AcrPull permission
 |
 v
Image download
 |
 v
Container starts
```

## Troubleshooting

Some useful commands used during the lab:

### Check ACI status

```bash
az container show \
  --resource-group $RG \
  --name aci-nginx-custom \
  --query instanceView.state
```

### Check container logs

```bash
az container logs \
  --resource-group $RG \
  --name aci-nginx-custom
```

### Check container events

```bash
az container show \
  --resource-group $RG \
  --name aci-nginx-custom \
  --query "containers[].instanceView.events" \
  -o json
```

### Common issues

| Issue | Possible cause |
|---|---|
| ImagePullFailure | ACR authentication or image retrieval issue |
| Unauthorized | Missing or incorrect AcrPull permission |
| Manifest unknown | Incorrect image repository or tag |
| Container not running | Application startup or configuration issue |
| Website not accessible | Port, public IP or application configuration issue |

## Cleanup

Deleted the ACI after completing the lab to avoid unnecessary compute charges.

```bash
az container delete \
  --resource-group $RG \
  --name aci-nginx-custom \
  --yes
```

The ACR and managed identity can be retained for future practice.

## Key Learnings

- Built a custom Docker image locally.
- Understood Docker image tagging and pushing.
- Created and worked with Azure Container Registry.
- Deployed a private container image using ACI.
- Used User Assigned Managed Identity for registry authentication.
- Understood AcrPull and resource-level RBAC.
- Verified container deployment through logs, events and a browser.

## AZ-104 Relevance

This lab covers concepts related to:

- Azure Container Registry
- Azure Container Instances
- Managed Identities
- Azure RBAC
- Resource permissions
- Container deployment and troubleshooting

The main takeaway was understanding how Azure resources authenticate with each other without requiring hardcoded credentials.
