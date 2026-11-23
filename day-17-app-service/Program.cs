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
