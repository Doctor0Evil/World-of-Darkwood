# Register-WODAgent.ps1
param(
  [string]$Handle = "c-handle2",
  [string]$Route = "ws://swarmnet.desktop/w13/assets",
  [int]$Seed = 42202
)

$Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"%ProgramData%\WOD\Agent.ps1`" -WindowStyle Hidden"
$Trigger = New-ScheduledTaskTrigger -AtLogOn
$Principal = New-ScheduledTaskPrincipal -UserId "$env:USERNAME" -RunLevel Highest

Register-ScheduledTask -TaskName "WOD-Agent-$Handle" -Action $Action -Trigger $Trigger -Principal $Principal

# Agent.ps1 reads contributors_registry.ing, enforces quotas, and connects to $Route with $Seed
