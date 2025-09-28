# Shared-Helpers.ps1
# Common functions used by Teams and Retention monitoring scripts

function Get-KeyVaultCredential {
    param (
        [string]$VaultName,
        [string]$UserSecret,
        [string]$PassSecret
    )
    $tokenResponse = Invoke-RestMethod -Uri "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://vault.azure.net" -Method GET -Headers @{Metadata = "true"}
    $kvToken = $tokenResponse.access_token

    $user = (Invoke-RestMethod -Uri "https://$VaultName.vault.azure.net/secrets/$UserSecret?api-version=7.1" -Headers @{Authorization = "Bearer $kvToken"}).value
    $pass = (Invoke-RestMethod -Uri "https://$VaultName.vault.azure.net/secrets/$PassSecret?api-version=7.1" -Headers @{Authorization = "Bearer $kvToken"}).value
    $secPass = ConvertTo-SecureString -String $pass -AsPlainText -Force
    return New-Object System.Management.Automation.PSCredential ($user, $secPass)
}

function Build-LogicAppPayload {
    param (
        [string]$Component,
        [array]$Changes,
        [string]$MessageType,
        [string]$Header,
        [array]$Baseline,
        [array]$Current
    )

    $table = foreach ($c in $Changes) {
        $desc = switch ($c.SideIndicator) {
            '=>' { 'Removed from tenant' }
            '<=' { 'Added to tenant' }
            Default { 'Modified' }
        }
        [PSCustomObject]@{
            Component     = $c.InputObject
            Description   = $desc
            SideIndicator = $c.SideIndicator
        }
    }

    return (@{
        component         = $Component
        title             = if ($Changes) { "$MessageType - Deviations Found" } else { "$MessageType - No Deviations" }
        MessageType       = $MessageType
        Message           = "$MessageType check completed."
        Details           = "Baseline vs current comparison attached."
        MessageTypeColor  = if ($Changes) { "Attention" } else { "Good" }
        TableColumns      = @("Component", "Description", "SideIndicator")
        Table             = $table
        BaselineContent   = ($Baseline -join "`n")
        CurrentContent    = ($Current -join "`n")
    } | ConvertTo-Json -Depth 8)
}
