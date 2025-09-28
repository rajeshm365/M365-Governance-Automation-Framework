# Monitor-RetentionPolicy.ps1
# Checks Microsoft Purview Retention Policy distribution status against baseline
# Triggers: Azure Automation Runbook (twice daily)

Param (
    [string]$KeyVaultName,
    [string]$UserSecretName,
    [string]$PasswordSecretName,
    [string]$LogicAppURI,
    [string]$BaselinePath = "C:\Baselines\retention_status.txt",
    [string]$CurrentPath = "C:\Temp\retention_current.txt"
)

. "$PSScriptRoot\Shared-Helpers.ps1"

$cred = Get-KeyVaultCredential -VaultName $KeyVaultName -UserSecret $UserSecretName -PassSecret $PasswordSecretName
Connect-IPPSSession -Credential $cred

Get-RetentionCompliancePolicy -DistributionDetail | Select Name, DistributionStatus | Format-Table -HideTableHeaders | Out-File -FilePath $CurrentPath

$baseline = Get-Content $BaselinePath
$current = Get-Content $CurrentPath
$changes = Compare-Object $baseline $current

$payload = Build-LogicAppPayload -Component "Microsoft Purview" -Changes $changes -MessageType "Purview Retention Policy Monitoring" -Header "Purview Retention Policy - Deviation Check" -Baseline $baseline -Current $current

Invoke-WebRequest -Uri $LogicAppURI -Method POST -Body $payload -ContentType 'application/json'
Remove-Item $CurrentPath -ErrorAction SilentlyContinue
