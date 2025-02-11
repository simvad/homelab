using Microsoft.AspNetCore.SignalR;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddSignalR();
builder.Services.AddCors();

var app = builder.Build();

app.UseCors(builder => builder
    .AllowAnyHeader()
    .AllowAnyMethod()
    .SetIsOriginAllowed(_ => true)
    .AllowCredentials()
);

// Simple in-memory state
var powerState = "Off";
var services = new Dictionary<string, bool>();
var builds = new Dictionary<string, string>();

app.MapHub<HomelabHub>("/homelab");
app.MapGet("/", () => "HomeLab SignalR Server");

app.Run();

class HomelabHub : Hub 
{
    public async Task UpdatePowerState(string state)
    {
        await Clients.All.SendAsync("PowerStateChanged", state);
    }

    public async Task UpdateService(string name, bool running)
    {
        await Clients.All.SendAsync("ServiceStateChanged", name, running);
    }

    public async Task NotifyBuild(string project, string status)
    {
        await Clients.All.SendAsync("BuildStatusUpdated", project, status);
    }

    public async Task UpdateMetrics(double cpu, double memory, double disk)
    {
        await Clients.All.SendAsync("MetricsUpdated", cpu, memory, disk);
    }
}