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
    A[Azure Automation - scheduled runbook] --> B[Hybrid Worker VM]
    B --> PS1[Monitor-TeamsSettings ps1]
    B --> PS2[Monitor-RetentionPolicy ps1]

    subgraph Shared Helpers
      H1[Get-KeyVaultCredential - fetch secrets]
      H2[Build-LogicAppPayload - build adaptive card payload]
    end

    PS1 --> H1
    PS2 --> H1
    H1 --> KV[Azure Key Vault - service account secrets]
    H1 --> PS1
    H1 --> PS2

    %% Service connections per script
    PS1 --> CONN1[Connect MicrosoftTeams and Graph]
    PS2 --> CONN2[Connect IPPSSession - Exchange Online]

    %% Current state retrieval
    CONN1 --> CUR1[Get current Teams app permission policies]
    CONN2 --> CUR2[Get Purview retention policy distribution status]

    %% Baseline read and comparison
    PS1 --> BASE[Read baseline txt files]
    PS2 --> BASE
    BASE --> COMP[Compare current vs baseline]

    %% Build payload then post to Logic App
    COMP --> H2
    H2 --> POST[HTTP POST to Logic App endpoint]
    POST --> LA[Azure Logic App]
    LA --> TEAMS[Microsoft Teams - adaptive card v1 dot 6]
