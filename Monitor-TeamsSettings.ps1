# Monitor-TeamsSettings.ps1
# Checks Microsoft Teams Admin Center settings against baseline
# Triggers: Azure Automation Runbook (twice daily)

Param (
    [string]$KeyVaultName,
    [string]$UserSecretName,
    [string]$PasswordSecretName,
    [string]$LogicAppURI,
    [string]$BaselinePath = "C:\Baselines\teams_settings.txt",
    [string]$CurrentPath = "C:\Temp\teams_current.txt"
)

. "$PSScriptRoot\Shared-Helpers.ps1"

$cred = Get-KeyVaultCredential -VaultName $KeyVaultName -UserSecret $UserSecretName -PassSecret $PasswordSecretName
Connect-MicrosoftTeams -Credential $cred

Get-CsTeamsAppPermissionPolicy -Identity Global | Select -ExpandProperty DefaultCatalogApps | Out-File -FilePath $CurrentPath

$baseline = Get-Content $BaselinePath
$current = Get-Content $CurrentPath
$changes = Compare-Object $baseline $current

$payload = Build-LogicAppPayload -Component "Microsoft Teams" -Changes $changes -MessageType "Teams Admin Settings Monitoring" -Header "Teams Admin Settings - Deviation Check" -Baseline $baseline -Current $current

Invoke-WebRequest -Uri $LogicAppURI -Method POST -Body $payload -ContentType 'application/json'
Remove-Item $CurrentPath -ErrorAction SilentlyContinue
