```

- **Fluidity:** Capabilities drive animation blending; contracts adapt envelopes instead of hard stats.
- **Transparency:** Approvals produce human‑readable explanations without exposing system operations in‑game.
- **Determinism:** Seeds bind to assets + session; placements reproduce exactly for auditing.

---

# Procedural generation invisibility protocols

The world should feel intentional—never like a machine shuffled it. We’ll hide orchestration while preserving verifiability.

- **Streaming:** Prewarm asset shells and motion clips into memory under budgeted streams.
- **Occlusion:** **Deferred realization** until objects are behind geometry boundaries or off‑camera.
- **Prefetch:** **Predictive pathing** from player intent; load adjacent cells and likely encounter sets.
- **Imposters:** **Low‑fidelity stand‑ins** swap to assets under animation synchronization at frame‑accurate moments.
- **Server‑auth:** **Authoritative placements** emit ledger events; client receives only realized deltas, never raw agent actions.
- **Time slicing:** **Micro‑tasks** for placement checks; never block input or animation loops.
- **Backpressure:** **Budget caps** on placements per tick; overflow defers with invisible cues.

```yaml
# File: policies/streaming.yml
streaming:
  budgets:
    max_realizations_per_500ms: 3
    max_animation_blends_per_500ms: 5
  occlusion:
    require_geometry_blocking: true
    defer_ms_min: 50
    defer_ms_max: 250
  prefetch:
    radius_cells: 2
    heuristic: "intent+velocity+camera"
```

---

# Character development without clunky stats

We’ll define characters as capability envelopes, affinities, and narrative flags. Progression is experiential, not numeric.

- **Identity:** **Archetype + vocation** (e.g., Wanderer / Wayfinder).
- **Capabilities:** **Envelopes** for movement, interaction, perception—ranges, not numbers.
- **Affinities:** **Qualitative tags** (woodcraft, lore-binding, pactkeeping) that unlock behaviors and dialogue.
- **Narrative flags:** **Persistent states** (oaths, scars, bonds) that drive story branching.
- **Skill web:** **Graph of learned motifs**; unlocks combos and animation palettes instead of raw stats.
- **Reputation:** **Dynamic graph** with factions; impacts opportunities and risk, not HP bars.

```json
// File: assets/npc/wanderer_profile.json
{
  "archetype": "Wanderer",
  "vocation": "Wayfinder",
  "capabilities": {
    "movement": { "envelope": ["stealth_step", "hill_climb", "ledge_balance"] },
    "interaction": { "envelope": ["campcraft", "trail_mark", "bind_wound"] },
    "perception": { "envelope": ["night_listen", "scent_track", "horizon_scan"] }
  },
  "affinities": ["woodcraft", "lore_binding", "pactkeeping"],
  "narrative_flags": { "oath_stone": true, "scar_silent": true, "bond_raven": false },
  "skill_web": ["quiet_fire", "wind_read", "line_cast"],
  "reputation": { "factions": { "Wardens": "trusted", "Tidebound": "unknown" } }
}
```

- **Animations:** Capability envelopes map to animation palettes; blending is contextual, not stat‑gated.
- **Progression:** Flags and affinities unlock behaviors, encounters, and narrative scenes.

---

# ALN and AII swarmnet scaffolds for virtual hardware projection

You want research lanes for virtually‑dependent hardware, projected as remote desktops launched via chat platforms. We’ll scaffold ALN workflows and AII policies to keep it portable and audit‑stamped.

```aln
# File: ops/virtual_hardware_projection.aln
run "vh_project" {
  input: "configs/virt/projection.yml"
  output: "logs/actions/vh_projection.log"
  steps:
    - allocate_virtual_gpu("budget:low", "cap:animation_preview")
    - mount_filesystem("sandbox:assets", "read_only:true")
    - start_remote_desktop("profile:creator", "stream:wasm_channel")
    - attach_policy("nanoswarm.session.v1")
    - emit("ledger:event", kind: "vh_session_start")
}
```

```yaml
# File: configs/virt/projection.yml
projection:
  transport: "wasm_channel"
  codec: "h264_low_latency"
  auth: "token"
  desktop_profile: "creator"
  fs_mounts:
    - path: "assets"
      mode: "ro"
    - path: "data/ledger"
      mode: "ro"
  gpu:
    vendor: "virtual"
    caps: ["skinning_preview", "shader_validation"]
```

```json
// File: policies/nanoswarm.aii
{
  "policy_id": "nanoswarm.session.v1",
  "entry": "session",
  "quotas": {
    "max_parallel_streams": 2,
    "max_placement_events_per_min": 30
  },
  "audit": {
    "require_chat_actor_id": true,
    "require_repo_ref": true,
    "log_sink": "logs/actions/nanoswarm_sessions.log"
  },
  "security": {
    "fs_readonly_mounts": ["assets", "data/ledger"],
    "deny_shell_exec": true,
    "allow_aln_tasks": ["vh_project", "generate_assets"]
  }
}
```

- **Launchability:** **ALN task** serves as the “button” chat platforms can trigger.
- **Safety:** **AII nanoswarm policy** restricts mounts, denies shell, forces attribution.
- **Projection:** **WASM channel** carries frames; codecs tuned for low‑latency previews.

---
