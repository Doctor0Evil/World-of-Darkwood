# File: 
param(
  [string]$Root = "C:\Users\Hunter\Windows-of-Death",
  [switch]$Force
)

$dirs = @(
  "assets\models", "assets\textures", "assets\materials", "assets\animations",
  "assets\audio", "assets\fx", "assets\biomes", "assets\quests", "assets\npc",
  "assets\props", "assets\ui", "assets\systems",
  "registry", "registry\schemas", "registry\approvals",
  "data\sqlite", "data\parquet", "data\ledger",
  "logs\actions", "logs\placements", "logs\approvals", "logs\errors"
)

foreach ($d in $dirs) { New-Item -ItemType Directory -Path (Join-Path $Root $d) -Force:$Force | Out-Null }

# Audit log initializer
$AuditLog = Join-Path $Root "logs\actions\audit.log"
if (!(Test-Path $AuditLog)) { New-Item -ItemType File -Path $AuditLog | Out-Null }

# Create baseline registry files
$RegistryFiles = @(
  "registry\assets.yml", "registry\biomes.yml", "registry\behaviors.yml",
  "registry\connectors.yml", "registry\schemas\sqlite.sql", "registry\schemas\parquet.yml",
  "registry\approvals\wasm-contracts.json"
)

foreach ($f in $RegistryFiles) {
  $p = Join-Path $Root $f
  if (!(Test-Path $p) -or $Force) { New-Item -ItemType File -Path $p | Out-Null }
}

"$(Get-Date -Format o) | INIT | AssetDB initialized at $Root" | Add-Content $AuditLog
Write-Host "Initialized asset database scaffolding at $Root"
```

- **Scope:** Creates portable directories, audit logs, and baseline registry files.
- **Repro:** Use the same script in CI to stamp sessions and ensure identical layouts.
- **Next:** Run with PowerShell in user‑space—no admin required.
