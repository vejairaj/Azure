# Day 18 – Azure Container Registry (ACR) and Azure Container Instances (ACI)

## Overview

In this lab, I built a custom NGINX Docker image, pushed it to Azure Container Registry, and deployed it using Azure Container Instances.

Instead of using registry credentials, I configured a User Assigned Managed Identity to authenticate ACI with ACR.

The objective was to understand how Azure handles private container image authentication and deployment.

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
  v
User Assigned Managed Identity
  |
  | Authentication
  v
Azure Container Instance
  |
  v
NGINX - HTTP Port 80
```

## Azure Resources

| Resource | Name |
|---|---|
| Resource Group | rg-day18-containers |
| Container Registry | Newly created ACR |
| Container Image | nginx-custom:v1 |
| Managed Identity | id-day18-acr-pull |
| ACI | aci-nginx-custom |
| Container Port | 80 |
| Registry SKU | Basic |

## What I implemented

1. Created a new Azure Container Registry.
2. Created a custom NGINX image using a Dockerfile.
3. Built the image for Linux AMD64.
4. Authenticated with Azure Container Registry.
5. Tagged and pushed the image to ACR.
6. Reused an existing User Assigned Managed Identity.
7. Assigned the AcrPull role on the new ACR.
8. Deployed the private image using Azure Container Instances.
9. Verified the deployment through container logs and a browser.
10. Practised the troubleshooting and cleanup commands.

## Important concepts learned

### Azure Container Registry

ACR is a private container registry used to store and manage container images.

### Azure Container Instances

ACI allows me to run containers in Azure without managing virtual machines or Kubernetes clusters.

### Managed Identity

Managed Identity provides an identity to Azure resources without requiring me to store usernames, passwords or registry credentials.

### AcrPull

The AcrPull role allows an identity to download container images from Azure Container Registry.

An important point I learned: permissions assigned on one registry do not automatically apply to another registry.

## Authentication flow

When ACI starts, it uses the configured User Assigned Managed Identity to authenticate with ACR.

ACR checks whether that identity has the required AcrPull permission.

If authorization succeeds, ACI can download the image and start the container.

## Verification

I verified that:

- The image was available in ACR.
- The ACI deployment completed successfully.
- The container entered the Running state.
- NGINX started successfully.
- The application was accessible through its public FQDN over HTTP.

## Cleanup

I deleted the ACI after completing the lab to avoid unnecessary compute charges.

The ACR and managed identity can be retained for further practice.

## Key takeaway

This lab helped me understand the complete workflow of building a custom container image, storing it in a private registry, configuring identity-based authentication, and running it in Azure.

It also helped me understand how managed identities and RBAC work together in a real Azure administration scenario.
