function Write-WoDLog {
    param([string]$Message)
    $LogEntry = @{
        timestamp = Get-Date -Format "o"
        message   = $Message
        actor     = "wolfman-dev"
    } | ConvertTo-Json
    Add-Content -Path "./logs/session-$(Get-Date -Format 'yyyyMMdd').jsonl" -Value $LogEntry
}
