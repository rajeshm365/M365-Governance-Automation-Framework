# Teams & Purview Policy Monitoring

⚡ Modular PowerShell + Azure Automation + Logic App framework to monitor Microsoft Teams admin settings and Purview retention policies.  
Designed for modular growth — easily extendable with new compliance and governance checks.

---

## ⚙️ Technologies Used

- **PowerShell Modules**
  - `MicrosoftTeams`
  - `Microsoft.Graph`
  - `ExchangeOnlineManagement` (for `Connect-IPPSSession`)
- **Azure Automation** + Hybrid Worker
- **Azure Key Vault** (secure credential storage)
- **Azure Logic App** + Teams Connector
- **Adaptive Card Schema** v1.6

---

## 🧪 Script Overview

### Monitor-TeamsSettings.ps1
- Checks Teams App Permission Policies  
- Fetches service account credentials from Key Vault  
- Compares current values vs baseline `.txt` files  
- Sends adaptive card alert with:
  - Deviation table  
  - Full baseline + current state  

### Monitor-RetentionPolicy.ps1
- Retrieves distribution status of Purview Retention Policies  
- Same comparison + alerting pattern as Teams script  
- Reuses shared credential and payload logic  

### Shared-Helpers.ps1
- `Get-KeyVaultCredential` → Pull secrets from Key Vault via managed identity  
- `Build-LogicAppPayload` → Format Teams-friendly payload with table, metadata, baseline, and current config  

---

## 🏗️ Architecture

```mermaid
flowchart TD
    A[Azure Automation - Scheduled Runbook] --> B[Hybrid Worker VM]
    B --> PS1[Monitor-TeamsSettings.ps1]
    B --> PS2[Monitor-RetentionPolicy.ps1]

    subgraph Shared Helpers
      H1[Get-KeyVaultCredential - fetch creds]
      H2[Build-LogicAppPayload - format alert]
    end

    PS1 --> H1
    PS2 --> H1
    H1 --> KV[Azure Key Vault - Service Account Secrets]

    PS1 --> COMP[Compare current vs baseline .txt]
    PS2 --> COMP

    COMP --> H2
    H2 --> LA[Azure Logic App]

    LA --> TEAMS[Microsoft Teams - Adaptive Card v1.6]
