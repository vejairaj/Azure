# Day 18 – Azure Container Architecture

## 1. Architecture Overview

The objective of this lab was to build a custom NGINX container image locally, store it in Azure Container Registry, and deploy it using Azure Container Instances.

A User Assigned Managed Identity was used to authenticate ACI with the private container registry.

### Architecture Diagram

```text
                  LOCAL ENVIRONMENT
              ┌──────────────────────┐
              │                      │
              │       My Mac         │
              │                      │
              │  Dockerfile          │
              │  index.html          │
              │       |              │
              │       v              │
              │  nginx-custom:v1     │
              │                      │
              └──────────┬───────────┘
                         |
                         | Docker push
                         v
                 AZURE ENVIRONMENT

          ┌────────────────────────────┐
          │                            │
          │  Azure Container Registry  │
          │                            │
          │  nginx-custom:v1            │
          │                            │
          └─────────────┬──────────────┘
                        |
                        | AcrPull
                        |
          ┌─────────────v──────────────┐
          │                            │
          │  User Assigned             │
          │  Managed Identity          │
          │                            │
          │  id-day18-acr-pull         │
          │                            │
          └─────────────┬──────────────┘
                        |
                        | Identity-based
                        | authentication
                        v
          ┌────────────────────────────┐
          │                            │
          │ Azure Container Instances  │
          │                            │
          │  aci-nginx-custom           │
          │                            │
          │  nginx-custom:v1            │
          │                            │
          │  CPU: 1                    │
          │  Memory: 1.5 GB            │
          │  Port: 80                  │
          │                            │
          └─────────────┬──────────────┘
                        |
                        | HTTP
                        v
                  Public IP / FQDN
                        |
                        v
                   Web Browser
```

## 2. Component Responsibilities

| Component | Responsibility |
|---|---|
| Docker | Builds the container image |
| Dockerfile | Defines how the image is built |
| Azure Container Registry | Stores private container images |
| Microsoft Entra ID | Provides identity authentication |
| User Assigned Managed Identity | Provides an identity for ACI |
| Azure RBAC | Controls access to ACR |
| AcrPull | Allows image-pull operations |
| Azure Container Instances | Runs the container |
| Public IP / FQDN | Provides access to the application |

## 3. Image Push Flow

The image push operation happens from my local machine.

```text
Docker Image
     |
     v
az acr login
     |
     v
Authenticate local Docker client
     |
     v
Docker tag
     |
     v
myregistry.azurecr.io/nginx-custom:v1
     |
     v
docker push
     |
     v
Azure Container Registry
```

My Azure CLI authentication is used to authorize the local push operation.

The ACI managed identity is not involved in this push operation.

## 4. Image Pull Flow

The image pull operation happens when ACI deploys the private image.

```text
ACI deployment
     |
     v
ACI uses configured
User Assigned Managed Identity
     |
     v
Microsoft Entra ID
     |
     v
ACR authorization check
     |
     v
AcrPull permission verified
     |
     v
Image downloaded from ACR
     |
     v
Container starts
```

This avoids storing registry passwords in the ACI configuration.

## 5. Managed Identity and RBAC

The User Assigned Managed Identity used in this lab:

`id-day18-acr-pull`

The identity was assigned the following role:

| Setting | Value |
|---|---|
| Identity | id-day18-acr-pull |
| Role | AcrPull |
| Scope | Newly created ACR |
| Purpose | Pull private container images |

### Why assign AcrPull on the new ACR?

Azure RBAC permissions are scoped.

If an identity has AcrPull on Registry A, it does not automatically receive AcrPull on Registry B.

Therefore, I assigned the role separately on the new registry.

## 6. Push vs Pull Authentication

This is an important distinction.

| Operation | Identity / Authentication |
|---|---|
| Push image from Mac | Azure CLI authentication through `az acr login` |
| Pull image into ACI | User Assigned Managed Identity |
| Authorize image pull | AcrPull role assignment |

Both operations access the same ACR, but they use different authentication paths.

## 7. Network Flow

After deployment, ACI exposes the NGINX container through a public endpoint.

```text
User Browser
     |
     | HTTP Request
     | Port 80
     v
ACI Public FQDN
     |
     v
Container Port 80
     |
     v
NGINX Web Server
     |
     v
Custom index.html
     |
     v
HTTP Response
```

The application was successfully accessed through the ACI public FQDN.

## 8. Troubleshooting Flow

When a container fails to deploy, investigate in sequence:

```text
Check ACR Repository
       |
       v
Check Image Tag
       |
       v
Check Managed Identity
       |
       v
Check AcrPull Permission
       |
       v
Check ACI Image Pull Events
       |
       v
Check Container Logs
       |
       v
Check Runtime State
       |
       v
Check Public IP and Port
```

This helps identify whether the issue is related to image availability, authentication, authorization, container startup or network access.

## 9. Key Takeaway

This lab demonstrated how Azure services work together to deploy a private container image securely.

The most important concept was understanding that ACR stores images, ACI runs containers, Managed Identity provides authentication, and RBAC controls authorization.

The complete workflow is:

**Build → Tag → Push → Authenticate → Pull → Run → Verify**
