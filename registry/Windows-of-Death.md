---
### **📂 GitHub Repo Structure**
```
Windows-of-Death/
├── registry/
│   └── connectors.yml          # Core registry config
├── interpreters/
│   └── narrative.ps1           # ALN interpreter rules
├── payloads/
│   ├── place_asset.yml         # Asset placement payload
│   └── demo.aln                # Demo ALN script
├── scripts/
│   ├── place_asset.ps1         # Asset placement logic
│   └── Write-WoDLog.ps1        # Audit logger
├── agents/
│   └── snowflake-agent.yml     # Snowflake agent config
├── .gitmodules                 # Submodule definitions
├── .gitignore                  # Logs and temp files
└── README.md                   # Project setup
```

---

### **📄 File-by-File Breakdown (GitHub Paths)**

#### **1. `registry/connectors.yml`**
**GitHub Path**: `https://github.com/Doctor0Evil/Windows-of-Death/blob/main/registry/connectors.yml`
**Purpose**: Core registry config for ALN/Swarmnet/Snowflake.
```yaml
version: 1
registry_id: wod-user
seeds:
  build_seed: 1337
  session_seed_strategy: monotonic-increment
namespaces:
  - name: core
    quota:
      placements_per_session: 50
      max_concurrent_connectors: 5
connectors:
  - id: aln-parser
    type: interpreter
    script: ./interpreters/narrative.ps1
    audit: true
  - id: swarmnet-bitshell
    type: interpreter
    script: ./src/swarmnet/bitshell/bitshell-functions.ps1
    audit: true
  - id: snowflake-agent
    type: agent
    config: ./agents/snowflake-agent.yml
    audit: true
```

---

#### **2. `interpreters/narrative.ps1`**
**GitHub Path**: `https://github.com/Doctor0Evil/Windows-of-Death/blob/main/interpreters/narrative.ps1`
**Purpose**: ALN interpreter rules.
```powershell
param(
    [string]$Actor,
    [string]$Action,
    [string]$Asset,
    [string]$Target
)
Write-WoDLog -Message "Interpreted: $Actor $Action $Asset → $Target"
```

---

#### **3. `payloads/place_asset.yml`**
**GitHub Path**: `https://github.com/Doctor0Evil/Windows-of-Death/blob/main/payloads/place_asset.yml`
**Purpose**: Asset placement payload.
```yaml
actor: wolfman-dev
action: place_asset
asset: safehouse-kit.v1
target: core:silent-perimeter
reason: "AI-Assisted Asset Placement"
```

---

#### **4. `scripts/place_asset.ps1`**
**GitHub Path**: `https://github.com/Doctor0Evil/Windows-of-Death/blob/main/scripts/place_asset.ps1`
**Purpose**: Executes asset placement.
```powershell
$Asset = "safehouse-kit.v1"
$Target = "core:silent-perimeter"
Write-WoDLog -Message "Placing $Asset → $Target"
& "./src/swarmnet/bitshell/bitshell-functions.ps1" -Asset $Asset -Target $Target
```

---

#### **5. `scripts/Write-WoDLog.ps1`**
**GitHub Path**: `https://github.com/Doctor0Evil/Windows-of-Death/blob/main/scripts/Write-WoDLog.ps1`
**Purpose**: Audit logger.
```powershell
function Write-WoDLog {
    param([string]$Message)
    $LogEntry = @{
        timestamp = Get-Date -Format "o"
        message   = $Message
        actor     = "wolfman-dev"
    } | ConvertTo-Json
    Add-Content -Path "./logs/session-$(Get-Date -Format 'yyyyMMdd').jsonl" -Value $LogEntry
}
```

---

#### **6. `agents/snowflake-agent.yml`**
**GitHub Path**: `https://github.com/Doctor0Evil/Windows-of-Death/blob/main/agents/snowflake-agent.yml`
**Purpose**: Snowflake agent config.
```yaml
agent_id: snowflake-ai
type: external
entrypoint: fetch.py
capabilities:
  - orchestration
  - nanoswarm
compliance:
  audit: true
```

---

#### **7. `payloads/demo.aln`**
**GitHub Path**: `https://github.com/Doctor0Evil/Windows-of-Death/blob/main/payloads/demo.aln`
**Purpose**: Demo ALN script.
```aln
actor hunter-dev
action place_asset
asset door-iron-01
target core:test-lab
reason "Demo ALN → Bitshell → Snowflake chain"
```

---

#### **8. `.gitmodules`**
**GitHub Path**: `https://github.com/Doctor0Evil/Windows-of-Death/blob/main/.gitmodules`
**Purpose**: Submodule definitions.
```ini
[submodule "src/aln-parser"]
    path = src/aln-parser
    url = https://github.com/Doctor0Evil/ALN-Programming-Language.git
[submodule "src/swarmnet"]
    path = src/swarmnet
    url = https://github.com/Doctor0Evil/swarmnet.git
```

---

#### **9. `.gitignore`**
**GitHub Path**: `https://github.com/Doctor0Evil/Windows-of-Death/blob/main/.gitignore`
**Purpose**: Ignore logs/temp files.
```gitignore
logs/
temp/
*.log
```

---

#### **10. `README.md`**
**GitHub Path**: `https://github.com/Doctor0Evil/Windows-of-Death/blob/main/README.md`
**Purpose**: Project setup.
```markdown
# Windows-of-Death Sandbox
## Setup
```bash
git clone --recurse-submodules https://github.com/Doctor0Evil/Windows-of-Death.git
cd Windows-of-Death
```
## Usage
```powershell
# Run ALN Parser
powershell -File ./src/aln-parser/aln.ps1 ./payloads/demo.aln
```
```

---

### **🚀 Deployment Steps**
1. **Create repo**:
   ```bash
   gh repo create Windows-of-Death --public
   ```
2. **Push files**:
   ```bash
   git add .
   git commit -m "Initial scaffold"
   git push
   ```
3. **Clone with submodules**:
   ```bash
   git clone --recurse-submodules https://github.com/Doctor0Evil/Windows-of-Death.git
   ```

---

### **✅ Key Features**
- **No local paths**: All scripts use relative paths.
- **Submodules**: Auto-included via `.gitmodules`.
- **Audit logs**: Written to `./logs/` (ignored by Git).
