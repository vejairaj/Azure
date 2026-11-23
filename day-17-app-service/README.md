# Azure App Service Administration — Day 17 Lab

## Project Overview
Deployed and configured a .NET 10 web application using Azure App Service, Azure CLI and Linux-based hosting.

## 1. Azure Resources

| Resource | Name |
|---|---|
| Resource Group | `rg-day17-appservice` |
| App Service Plan | `ASP-rgday17appservice-9937` |
| Web App | `webapp-day17-lab-73921` |
| Region | West US 3 |
| OS | Linux |
| Runtime | .NET 10 |
| Pricing Tier | Free F1 |
| HTTPS Only | Enabled |

## 2. Create Resource Group

```bash
az group create \
  --name rg-day17-appservice \
  --location westus3
```

## 3. Create App Service Plan

```bash
az appservice plan create \
  --name asp-day17-lab \
  --resource-group rg-day17-appservice \
  --location westus3 \
  --sku FREE \
  --is-linux
```

*Note: The actual plan created through the Portal was `ASP-rgday17appservice-9937`.*

## 4. Create Web App

```bash
az webapp create \
  --resource-group rg-day17-appservice \
  --plan ASP-rgday17appservice-9937 \
  --name webapp-day17-lab-73921 \
  --runtime "DOTNETCORE:10.0"
```

## 5. Configure Application Settings

```bash
az webapp config appsettings set \
  --resource-group rg-day17-appservice \
  --name webapp-day17-lab-73921 \
  --settings APP_ENV=Learning
```

Verify:

```bash
az webapp config appsettings list \
  --resource-group rg-day17-appservice \
  --name webapp-day17-lab-73921 \
  --query "[?name=='APP_ENV']" \
  --output table
```

## 6. Configure Connection String

```bash
az webapp config connection-string set \
  --resource-group rg-day17-appservice \
  --name webapp-day17-lab-73921 \
  --connection-string-type SQLAzure \
  --settings DefaultConnection="Server=localhost;Database=TrainingDB;"
```

*Placeholder connection string for configuration practice; no database was created.*

## 7. Enable System-Assigned Managed Identity

```bash
az webapp identity assign \
  --resource-group rg-day17-appservice \
  --name webapp-day17-lab-73921
```

Verify:

```bash
az webapp identity show \
  --resource-group rg-day17-appservice \
  --name webapp-day17-lab-73921 \
  --output table
```

## 8. Create .NET Web Application

```bash
dotnet new web -n Day17DemoApp
cd Day17DemoApp
```

### Program.cs

```csharp
var builder = WebApplication.CreateBuilder(args);

var app = builder.Build();

app.MapGet("/", () =>
{
    var environment =
        Environment.GetEnvironmentVariable("APP_ENV")
        ?? "Not configured";

    return Results.Content(
        $"<h1>Day 17 App Service Lab</h1>" +
        $"<p>Environment: {environment}</p>" +
        "<p>Hosted on Azure App Service</p>",
        "text/html");
});

app.Run();
```

## 9. Publish Application

```bash
dotnet publish -c Release -o ./publish
```

Create ZIP package from the published files:

```bash
cd publish
zip -r ../app.zip .
cd ..
```

*Important: ZIP the contents of the publish directory, not the publish directory itself.*

## 10. Deploy Using ZIP Deployment

```bash
az webapp deploy \
  --resource-group rg-day17-appservice \
  --name webapp-day17-lab-73921 \
  --src-path app.zip \
  --type zip
```

## 11. Verify Deployment History

```bash
az webapp log deployment list \
  --resource-group rg-day17-appservice \
  --name webapp-day17-lab-73921 \
  --output table
```

## 12. Verify Application Configuration

```bash
az webapp config appsettings list \
  --resource-group rg-day17-appservice \
  --name webapp-day17-lab-73921 \
  --query "[?name=='APP_ENV']" \
  --output table
```

## 13. Restart Web App

```bash
az webapp restart \
  --resource-group rg-day17-appservice \
  --name webapp-day17-lab-73921
```

## 14. Test Live Application

```bash
curl -i https://webapp-day17-lab-73921-b5f3fhhwd7ane7bg.westus3-01.azurewebsites.net
```

### Expected Output

```html
<h1>Day 17 App Service Lab</h1>
<p>Environment: Learning</p>
<p>Hosted on Azure App Service</p>
```
