using Microsoft.AspNetCore.SignalR.Client;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddRazorPages();
builder.Services.AddServerSideBlazor();

// Add SignalR client as singleton
builder.Services.AddSingleton<HubConnection>(_ => {
    return new HubConnectionBuilder()
        .WithUrl("http://localhost:5000/homelab")
        .WithAutomaticReconnect()
        .Build();
});

var app = builder.Build();

app.UseStaticFiles();
app.UseRouting();
app.MapBlazorHub();
app.MapFallbackToPage("/_Host");

app.Run();