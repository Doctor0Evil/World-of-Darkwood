$Asset = "safehouse-kit.v1"
$Target = "core:silent-perimeter"
Write-WoDLog -Message "Placing $Asset → $Target"
& "./src/swarmnet/bitshell/bitshell-functions.ps1" -Asset $Asset -Target $Target
