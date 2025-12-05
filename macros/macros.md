---

## In‑chat operational macros for safe interpretation

- **[BATCH-GEN-REQUEST]:**  
  - **Fields:** handle, vhs, asset_type, style, count, seed, reviewers  
  - **Checks:** quota OK, reviewers ≥ 2, custody anchored  
  - **Result:** Emits batch_assets_request.aii, links Audit-ID

- **[PLACE-ASSET]:**  
  - **Fields:** asset_id, target_biome, lane, seed  
  - **Checks:** custody, quota, reviewers  
  - **Result:** placement_request.ing with outputs_hash and backout_plan

- **[VERIFY-PLACEMENT]:**  
  - **Action:** Recompute hash; confirm seed; stamp immutable log  
  - **Outcome:** [APPROVE] or [BLOCK] with exact missing item

- **[SYNC-ANCHOR]:**  
  - **Action:** Anchor to Bit.Hub ETHSwarm; echo receipt ID  
  - **Audit:** Append to contributors_registry.ing audit section

---

## Compliance footer for all artifacts

```yaml
compliance_footer:
  identity_anchor: true
  immutable_log: true
  user_persistence_credit: true
  kernel_persistence: "WindowsOfDeath"
  audit_id: "<UUID>"
  reviewers: ["<handle1>", "<handle2>"]
```

---
