
---

## ⚙️ Technologies Used

- PowerShell Modules:
  - `MicrosoftTeams`
  - `Microsoft.Graph`
  - `ExchangeOnlineManagement` (for IPPSSession)
- Azure Automation + Hybrid Worker
- Azure Key Vault (Managed Identity)
- Azure Logic App + Teams Connector
- Adaptive Card Schema v1.6

---

## 🧪 Script Overview

### Monitor-TeamsSettings.ps1

- Checks Teams App Permission Policies
- Uses Key Vault to securely fetch service account credentials
- Compares current and baseline values from `.txt` files
- Sends adaptive card alert with:
  - Deviation table
  - Full baseline + current state

### Monitor-RetentionPolicy.ps1

- Retrieves distribution status of Purview Retention Policies
- Identical pattern as Teams script
- Reuses the shared payload/credential logic

### Shared-Helpers.ps1

- `Get-KeyVaultCredential`: Pulls secrets via managed identity
- `Build-LogicAppPayload`: Prepares Teams-friendly payload with table, metadata, baseline, and current config

---

## 🔔 Alert Format (in Teams)

- **Header**: `Teams Admin Settings Monitoring - Deviations Found`
- **Deviation Table**: Rendered in adaptive card (Component | Description | SideIndicator)
- **Current + Baseline Content**: Shown below the table for context

---

## 📦 Deployment Steps

1. **Key Vault**
   - Add two secrets: service account UPN and password

2. **Automation Account**
   - Import both `.ps1` scripts as Runbooks
   - Assign Hybrid Worker
   - Schedule twice daily

3. **Logic App**
   - Deploy `LogicApp-TeamsAlert.json`
   - Configure Teams connector and channel
   - Copy HTTP endpoint into your PowerShell `$LogicAppURI`

---

## 📌 Notes

- You can add more scripts into `/src/` for future checks (e.g. license monitoring, DLP scans, service plan alerts)
- This repo is modular by design
- Tables rendered inside Logic App, not by PowerShell

---

## 🧠 Author

**Rajesh Singh Chaubey**  
Automation Engineer – HSBC  
Microsoft 365 Governance | Compliance-as-Code

---

## ✅ Status

🟢 Active — Adding new modules as needed for evolving Microsoft 365 risk surfaces.
