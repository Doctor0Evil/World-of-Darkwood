param(
    [string]$Actor,
    [string]$Action,
    [string]$Asset,
    [string]$Target
)
Write-WoDLog -Message "Interpreted: $Actor $Action $Asset → $Target"
