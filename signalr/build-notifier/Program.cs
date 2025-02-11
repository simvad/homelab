using Microsoft.AspNetCore.SignalR.Client;
using System.Windows.Forms;

var hubConnection = new HubConnectionBuilder()
    .WithUrl("http://localhost:5000/homelab")
    .WithAutomaticReconnect()
    .Build();

var notifyIcon = new NotifyIcon
{
    Icon = new System.Drawing.Icon(System.Drawing.SystemIcons.Application, 40, 40),
    Text = "HomeLab Build Monitor",
    Visible = true
};

// Create context menu
var menu = new ContextMenuStrip();
menu.Items.Add("Exit", null, (s, e) => Application.Exit());
notifyIcon.ContextMenuStrip = menu;

// Set up file watcher
var watcher = new FileSystemWatcher
{
    Path = @"B:\",
    NotifyFilter = NotifyFilters.LastWrite | NotifyFilters.FileName,
    Filter = "*.complete"
};

watcher.Created += async (sender, e) => {
    var projectName = Path.GetFileNameWithoutExtension(e.Name);
    try
    {
        await hubConnection.InvokeAsync("NotifyBuild", projectName, "Completed");
        notifyIcon.ShowBalloonTip(3000, "Build Complete", $"Project: {projectName}", ToolTipIcon.Info);
    }
    catch (Exception ex)
    {
        notifyIcon.ShowBalloonTip(3000, "Error", $"Failed to notify build: {ex.Message}", ToolTipIcon.Error);
    }
};

// Start everything
await hubConnection.StartAsync();
watcher.EnableRaisingEvents = true;

// Run application
Application.Run();

// Cleanup
notifyIcon.Dispose();