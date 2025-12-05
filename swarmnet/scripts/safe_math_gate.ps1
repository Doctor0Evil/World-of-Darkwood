# SwarmNet Safety Gate: precision math + ethical compliance
# Ensures datastream corrections are safe, compliant, and sandboxed before any generation.
$ErrorActionPreference = "Stop"

# 1) Load compliance thresholds
$thresholds = @{
  MaxExternalContactProb = 0.0         # absolute no-contact
  MaxRiskScore           = 0.05         # conservative bound
  MinAuditConfidence     = 0.99
  MinReversibilityScore  = 0.995
}

# 2) Compute precision metrics (example deterministic calc)
function Invoke-PrecisionMath {
    param(
        [double]$pContact,
        [double]$risk,
        [double]$auditConf,
        [double]$reversibility
    )
    # Deterministic guard with tight tolerances
    $epsilon = 1e-12
    $safeContact      = ($pContact - 0.0) -lt $epsilon
    $safeRisk         = ($risk - $thresholds.MaxRiskScore) -lt -$epsilon
    $safeAudit        = ($auditConf - $thresholds.MinAuditConfidence) -gt -$epsilon
    $safeReversible   = ($reversibility - $thresholds.MinReversibilityScore) -gt -$epsilon
    return @{
        SafeContact    = $safeContact
        SafeRisk       = $safeRisk
        SafeAudit      = $safeAudit
        SafeReversible = $safeReversible
        OverallSafe    = ($safeContact -and $safeRisk -and $safeAudit -and $safeReversible)
    }
}

# 3) Load datastream correction manifests (example locations)
$manifests = Get-ChildItem -Path "./swarmnet/datastreams" -Filter "*.ing" -Recurse -ErrorAction SilentlyContinue
if (-not $manifests) {
    Write-Host "No datastream correction manifests found; passing by default with no asset generation."
    exit 0
}

# 4) Evaluate each manifest (placeholder parser; treat as INI-like)
foreach ($mf in $manifests) {
    $content = Get-Content $mf.FullName -Raw
    # Example extraction: expecting keys p_contact, risk, audit_conf, reversibility
    $pContact      = [double]([regex]::Match($content, "(?m)^p_contact\s*=\s*([0-9\.e-]+)$").Groups[1].Value)
    $risk          = [double]([regex]::Match($content, "(?m)^risk\s*=\s*([0-9\.e-]+)$").Groups[1].Value)
    $auditConf     = [double]([regex]::Match($content, "(?m)^audit_conf\s*=\s*([0-9\.e-]+)$").Groups[1].Value)
    $reversibility = [double]([regex]::Match($content, "(?m)^reversibility\s*=\s*([0-9\.e-]+)$").Groups[1].Value)
    if ($null -eq $pContact -or $null -eq $risk -or $null -eq $auditConf -or $null -eq $reversibility) {
        Write-Error "Manifest '$($mf.FullName)' missing required compliance keys."
    }
    $result = Invoke-PrecisionMath -pContact $pContact -risk $risk -auditConf $auditConf -reversibility $reversibility
    if (-not $result.OverallSafe) {
        Write-Error "Safety gate failed for '$($mf.FullName)': Contact=$($result.SafeContact), Risk=$($result.SafeRisk), Audit=$($result.SafeAudit), Reversible=$($result.SafeReversible)"
    } else {
        Write-Host "Safety gate passed for '$($mf.FullName)'"
    }
}
Write-Host "All manifests passed safety gates. Proceed with asset generation."

# Ensure directories
try {
    New-Item -ItemType Directory -Force -Path ".github/workflows" | Out-Null
    New-Item -ItemType Directory -Force -Path "swarmnet/scripts" | Out-Null
    New-Item -ItemType Directory -Force -Path "swarmnet/aln" | Out-Null
    New-Item -ItemType Directory -Force -Path "swarmnet/datastreams" | Out-Null
    New-Item -ItemType Directory -Force -Path "assets/generated" | Out-Null
    Write-Host "Created necessary directories."
} catch {
    Write-Error "Failed to create directories: $_"
    exit 1
}

# Write workflow: validate-and-autofix-gitattributes.yml
$workflow1 = @"
name: Validate and autofix .gitattributes via .magic
on:
  push:
    paths:
      - "swarmnet/.gitattributes.magic"
      - "swarmnet/.gitattributes"
  pull_request:
    paths:
      - "swarmnet/.gitattributes.magic"
      - "swarmnet/.gitattributes"
permissions:
  contents: write
jobs:
  validate-and-fix:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - name: Setup PowerShell
        uses: actions/setup-powershell@v2
      - name: Run .gitattributes.magic to regenerate
        working-directory: swarmnet
        run: pwsh ./.gitattributes.magic
      - name: Detect differences
        run: |
          git add swarmnet/.gitattributes
          if git diff --cached --quiet; then
            echo "No changes needed; .gitattributes is in sync."
          else
            echo "Regenerated .gitattributes differs; committing fix."
            git config user.name "swarmnet-ci"
            git config user.email "swarmnet-ci@users.noreply.github.com"
            git commit -m "CI: regenerate .gitattributes via .magic"
            git push
          fi
"@

try {
    $workflow1 | Out-File ".github/workflows/validate-and-autofix-gitattributes.yml" -Encoding utf8
    Write-Host "Created workflow: validate-and-autofix-gitattributes.yml"
} catch {
    Write-Error "Failed to create validate-and-autofix-gitattributes.yml: $_"
    exit 1
}

# Write workflow: darkwood2-asset-generator.yml
$workflow2 = @"
name: Darkwood2 safe asset generator
on:
  push:
    paths:
      - "swarmnet/datastreams/**"
      - "swarmnet/routes/**"
      - ".github/workflows/**"
      - "swarmnet/.gitattributes.magic"
  workflow_dispatch:
permissions:
  contents: write
jobs:
  generate-assets:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      - name: Setup PowerShell
        uses: actions/setup-powershell@v2
      - name: Safety gate (precision math + ethical compliance)
        run: pwsh ./swarmnet/scripts/safe_math_gate.ps1
      - name: Run asset generator (ALN)
        run: pwsh -c 'Write-Host "Invoking ALN generator"; ./swarmnet/aln/datastream_asset_generator.aln'
      - name: Commit generated assets
        run: |
          git add assets/ generated/** || true
          if git diff --cached --quiet; then
            echo "No asset changes to commit."
          else
            git config user.name "swarmnet-ci"
            git config user.email "swarmnet-ci@users.noreply.github.com"
            git commit -m "CI: auto-generate assets (safe datastream correction)"
            git push
          fi
"@

try {
    $workflow2 | Out-File ".github/workflows/darkwood2-asset-generator.yml" -Encoding utf8
    Write-Host "Created workflow: darkwood2-asset-generator.yml"
} catch {
    Write-Error "Failed to create darkwood2-asset-generator.yml: $_"
    exit 1
}

# Write safety gate script
$safetyGate = @'
# SwarmNet Safety Gate: precision math + ethical compliance
$ErrorActionPreference = "Stop"
$thresholds = @{ MaxExternalContactProb = 0.0; MaxRiskScore = 0.05; MinAuditConfidence = 0.99; MinReversibilityScore = 0.995 }
function Invoke-PrecisionMath {
    param([double]$pContact,[double]$risk,[double]$auditConf,[double]$reversibility)
    $epsilon = 1e-12
    $safeContact = ($pContact - 0.0) -lt $epsilon
    $safeRisk = ($risk - $thresholds.MaxRiskScore) -lt -$epsilon
    $safeAudit = ($auditConf - $thresholds.MinAuditConfidence) -gt -$epsilon
    $safeReversible = ($reversibility - $thresholds.MinReversibilityScore) -gt -$epsilon
    return @{ SafeContact=$safeContact; SafeRisk=$safeRisk; SafeAudit=$safeAudit; SafeReversible=$safeReversible; OverallSafe=($safeContact -and $safeRisk -and $safeAudit -and $safeReversible) }
}
$manifests = Get-ChildItem -Path "./swarmnet/datastreams" -Filter "*.ing" -Recurse -ErrorAction SilentlyContinue
if (-not $manifests) { Write-Host "No datastream correction manifests found; passing by default."; exit 0 }
foreach ($mf in $manifests) {
    $content = Get-Content $mf.FullName -Raw
    $pContact = [double]([regex]::Match($content, "(?m)^p_contact\s*=\s*([0-9\.e-]+)$").Groups[1].Value)
    $risk = [double]([regex]::Match($content, "(?m)^risk\s*=\s*([0-9\.e-]+)$").Groups[1].Value)
    $auditConf = [double]([regex]::Match($content, "(?m)^audit_conf\s*=\s*([0-9\.e-]+)$").Groups[1].Value)
    $reversibility = [double]([regex]::Match($content, "(?m)^reversibility\s*=\s*([0-9\.e-]+)$").Groups[1].Value)
    if ($null -eq $pContact -or $null -eq $risk -or $null -eq $auditConf -or $null -eq $reversibility) { Write-Error "Manifest '$($mf.FullName)' missing required compliance keys." }
    $r = Invoke-PrecisionMath -pContact $pContact -risk $risk -auditConf $auditConf -reversibility $reversibility
    if (-not $r.OverallSafe) { Write-Error "Safety gate failed for '$($mf.FullName)' (Contact=$($r.SafeContact), Risk=$($r.SafeRisk), Audit=$($r.SafeAudit), Reversible=$($r.SafeReversible))" } else { Write-Host "Safety gate passed for '$($mf.FullName)'" }
}
Write-Host "All manifests passed safety gates."
'@

try {
    $safetyGate | Out-File "swarmnet/scripts/safe_math_gate.ps1" -Encoding utf8
    Write-Host "Created script: safe_math_gate.ps1"
} catch {
    Write-Error "Failed to create safe_math_gate.ps1: $_"
    exit 1
}

# Write ALN generator
$alnGenerator = @'
# Datastream Asset Generator (Safe Mode)
BEGIN_PIPELINE:
  LOAD "swarmnet/datastreams/*.ing" AS DATASTREAMS
  FOR EACH STREAM IN DATASTREAMS:
    VALIDATE STREAM "p_contact == 0 && risk <= 0.05 && audit_conf >= 0.99 && reversibility >= 0.995"
    GENERATE ASSETS SAFE USING STREAM INTO "assets/generated/{STREAM.name}/"
    AUDIT LOG "generated-assets" WITH STREAM.METADATA
END_PIPELINE
'@

try {
    $alnGenerator | Out-File "swarmnet/aln/datastream_asset_generator.aln" -Encoding utf8
    Write-Host "Created ALN generator: datastream_asset_generator.aln"
} catch {
    Write-Error "Failed to create datastream_asset_generator.aln: $_"
    exit 1
}

# Commit all
try {
    git add .github/workflows/validate-and-autofix-gitattributes.yml `
            .github/workflows/darkwood2-asset-generator.yml `
            swarmnet/scripts/safe_math_gate.ps1 `
            swarmnet/aln/datastream_asset_generator.aln
    git commit -m "CI: auto-validate/fix .gitattributes via .magic; safe asset generator with precision math gates"
    git push
    Write-Host "Staged, committed, and pushed all files."
} catch {
    Write-Error "Failed to commit and push files: $_"
    exit 1
}
