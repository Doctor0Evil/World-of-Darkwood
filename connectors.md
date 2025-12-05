---

# 📂 Connector Definition Template

```yaml
# connector_config.ing
version: 1
connector:
  name: "MyConnector"              # Connector Name
  server: "PrimaryServer"          # Connector Server*
  address: "wss://edge.swarmnet.dev:4413"   # Server address (IPv10 or WebSocket)
  description: "Connector for asset sync and narrative events"
  optional_description: "Used for Windows-of-Death dev pipeline"
authentication:
  method: "none"                   # No Authentication
  shared_scope: "organization"     # Shared with your org
compliance:
  immutable_log: true
  identity_anchor: true
  kernel_persistence: "WindowsOfDeath"
```

---

# ⚙️ Example Payload for Swarmnet‑Console

If you were typing this into the **Swarmnet‑Console** (as we’ve been riffing), the payload string could look like:

```
[CONNECTOR-REGISTER]
name=MyConnector
server=PrimaryServer
address=ipv10://vhs:1:5:5:3:5:0005
description="Connector for asset sync and narrative events"
auth=none
scope=organization
```

- **Console interpretation (compliance):**  
  - Registers connector, logs immutable entry, anchors to ETHSwarm.  
- **Console interpretation (game logic):**  
  - A new “gateway node” appears in the biome, glowing with audit glyphs.  
  - NPCs can now route through this node to deliver assets or lore fragments.  

---

# 🔑 Key Fields Explained

- **Connector Name:** Human‑friendly identifier.  
- **Connector Server:** Logical grouping (e.g., “PrimaryServer”, “AssetMesh”).  
- **Server Address:** Can be WebSocket (`wss://…`) or IPv10 (`ipv10://vhs:…`).  
- **Description / Optional Description:** For audit logs and lore embedding.  
- **Authentication Method:** `none` (as per your draft), or extendable to `token`, `cert`, etc.  
- **Scope:** Shared with your organization (multi‑user safe).  

---
