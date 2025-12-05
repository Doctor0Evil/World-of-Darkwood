# automation/Register-WODAgent.ps1
param(
  [string]$Handle = "c-handle2",
  [string]$Route = "ws://swarmnet.desktop/w13/assets",
  [string]$IPv10 = "ipv10://vhs:1:2:4:3:5:0002",
  [int]$Seed = 42202
)

$Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"%ProgramData%\WOD\Agent.ps1`" -WindowStyle Hidden"
$Trigger = New-ScheduledTaskTrigger -AtLogOn
$Principal = New-ScheduledTaskPrincipal -UserId "$env:USERNAME" -RunLevel Highest

Register-ScheduledTask -TaskName "WOD-Agent-$Handle" -Action $Action -Trigger $Trigger -Principal $Principal

# %ProgramData%\WOD\Agent.ps1:
# - Reads configs/contributors_registry.ing
# - Validates quotas via automation/ChatOps_Governance.aln
# - Connects to $Route and tags sessions with $IPv10 and $Seed
# - Emits immutable logs and anchors to ETHSwarm
