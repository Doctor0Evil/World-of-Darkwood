# Web5 Gameplay with WASM Contracts and SHA256 PowerShell Security

## WASM Contract Instantiation for Swarmnet/Web5 Gameplay
1. Compile performance-critical modules (combat/NPC/core engine) to WASM using Rust, Go, or C++.
2. Deploy WASM contract to Web5-backed swarmnet environment with versioned `code_hash`
3. Instantiate contracts with `code_hash` to enable parallel execution
4. Game logic executes in WASM for high FPS/low latency with zero-visibility security

## PowerShell Security Commands

### Compute SHA256 Hash
```powershell
(Get-FileHash -Path .\configs\merchantSystem.ing -Algorithm SHA256).Hash
```

### Verify File Integrity
```powershell
$known = "44cf3a90a82b3ce21dd9b734ba450ad3e400a88b2cfa81aa4a2ec0bd4ba3eeec"
$actual = (Get-FileHash -Path .\configs\merchantSystem.ing -Algorithm SHA256).Hash
$known -eq $actual ? "Match" : "Mismatch"
```

### Create Hash Manifest File
```powershell
$hash = (Get-FileHash -Path .\configs\merchantSystem.ing -Algorithm SHA256).Hash
"$hash  merchantSystem.ing" | Out-File -FilePath .\merchantSystem.ing.sha256 -Encoding UTF8
```

## Secure File Writing Procedure
```powershell
# 1. Receive authenticated content
$content = Get-Content -Path "secure_source.aln" -Raw

# 2. Write as binary with UTF-8 encoding
[IO.File]::WriteAllText(".\configs\merchantSystem.ing", $content, [System.Text.Encoding]::UTF8)

# 3. Compute hash immediately
(Get-FileHash -Path .\configs\merchantSystem.ing -Algorithm SHA256).Hash
```

## Integrity Manifest (`configs/integrity.json`)
```json
{
  "configs": [
    {
      "name": "swarmnet-combat-and-delivery.ing",
      "sha256": "<fill-after-commit>",
      "path": "./configs/swarmnet-combat-and-delivery.ing"
    },
    {
      "name": "merchantSystem.ing",
      "sha256": "<fill-after-commit>",
      "path": "./configs/merchantSystem.ing"
    },
    {
      "name": "directorAI.ing",
      "sha256": "<fill-after-commit>",
      "path": "./configs/directorAI.ing"
    }
  ],
  "assets": [
    {
      "origin": "Z:\\",
      "iteration": "batch-001",
      "manifest": "./manifests/Z_batch-001.json"
    }
  ],
  "metadata": {
    "hmac": "<optional_hex_hmac>",
    "last_updated": "2023-11-15T00:00:00Z"
  }
}
```

## Implementation Workflow
1. Place `integrity.json` in `/configs/` directory
2. Update hashes using:
   ```powershell
   Get-ChildItem -Path .\configs\*.ing | ForEach-Object {
     $hash = (Get-FileHash -Path $_.FullName -Algorithm SHA256).Hash
     # Update integrity.json
   }
   ```
3. Commit both configs and integrity manifest

## Security Features
- WASM sandbox prevents runtime conflicts
- Pre-commit hooks enforce hash validation
- Swarmnet runtime enforces deny-first policy
- Automatic quarantine for hash mismatches

## References
[1] WASM Smart Contracts Guide
[2] Web5 Swarmnet Architecture
[3] PowerShell File Integrity Checks
```

Key improvements:
1. Proper Markdown structure with clear sections
2. Consistent PowerShell cmdlet usage
3. Added file paths to JSON for clarity
4. Simplified verification syntax
5. Removed duplicate/conflicting information
6. Added metadata fields to JSON
7. Improved command examples with proper parameters
