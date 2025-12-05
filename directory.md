---

# 📂 File Placement

```
/configs
  ├── connector_config.ing          # single connector template
  └── connectors_registry.ing       # multi-connector registry (new)
```

---

# 📝 connectors_registry.ing

```yaml
# configs/connectors_registry.ing
version: 1
sync_id: "WOD-CONNECTORS-001"

connectors:
  - name: "StoryConnector"
    server: "PrimaryServer"
    address: "ipv10://vhs:1:1:1:2:1:0001"
    description: "Handles narrative skeleton updates and lore hooks"
    authentication: "none"
    scope: "organization"
    sandbox_profile: "story-sbx"
    ws_route: "ws://swarmnet.desktop/w13/story"

  - name: "BiomeConnector"
    server: "BiomeServer"
    address: "ipv10://vhs:1:4:2:2:3:0004"
    description: "Manages biome definitions and visual assets"
    authentication: "none"
    scope: "organization"
    sandbox_profile: "biome-sbx"
    ws_route: "ws://swarmnet.desktop/w13/biomes"

  - name: "CombatConnector"
    server: "CombatServer"
    address: "ipv10://vhs:1:3:3:2:2:0003"
    description: "Routes combat kernel updates and NPC AI behaviors"
    authentication: "none"
    scope: "organization"
    sandbox_profile: "combat-sbx"
    ws_route: "ws://swarmnet.desktop/w13/combat"

  - name: "AssetConnector"
    server: "AssetServer"
    address: "ipv10://vhs:1:2:4:3:5:0002"
    description: "Delivers sprites, textures, and animation bundles"
    authentication: "none"
    scope: "organization"
    sandbox_profile: "asset-sbx"
    ws_route: "ws://swarmnet.desktop/w13/assets"

  - name: "PipelineConnector"
    server: "PipelineServer"
    address: "ipv10://vhs:1:5:5:3:5:0005"
    description: "CI/CD compliance and audit logging"
    authentication: "none"
    scope: "organization"
    sandbox_profile: "pipeline-sbx"
    ws_route: "ws://swarmnet.desktop/w13/pipeline"

  - name: "SyncConnector"
    server: "SyncServer"
    address: "ipv10://vhs:1:6:8:1:6:0006"
    description: "Mesh synchronization and identity anchoring"
    authentication: "none"
    scope: "organization"
    sandbox_profile: "sync-sbx"
    ws_route: "ws://swarmnet.desktop/w13/sync"

  - name: "QAConnector"
    server: "QAServer"
    address: "ipv10://vhs:1:7:7:2:7:0007"
    description: "Verification, backout, and compliance testing"
    authentication: "none"
    scope: "organization"
    sandbox_profile: "qa-sbx"
    ws_route: "ws://swarmnet.desktop/w13/qa"

  - name: "AIConnector"
    server: "AIServer"
    address: "ipv10://vhs:1:8:6:2:8:0008"
    description: "Visual learning aide and AI prompt contracts"
    authentication: "none"
    scope: "organization"
    sandbox_profile: "ai-sbx"
    ws_route: "ws://swarmnet.desktop/w13/ai"

compliance:
  immutable_log: true
  identity_anchor: true
  kernel_persistence: "WindowsOfDeath"
  user_persistence_credit: true

audit:
  reviewers_min: 2
  placement_policy: "manual-with-approval"
  backout_policy: "documented-and-scripted"
```

---

# ⚙️ How It Works

- **Each connector** has:
  - **IPv10 address** for routing  
  - **WebSocket route** for Edge/Swarmnet desktop integration  
  - **Sandbox profile** for safe execution  
  - **Compliance footer** (immutable log, kernel persistence, identity anchor)  

- **Registry file** allows you to:
  - Manage all connectors in one place  
  - Enforce consistent compliance rules  
  - Share connectors across your organization  

---
