-- File: registry/schemas/sqlite.sql

CREATE TABLE IF NOT EXISTS asset_catalog (
  asset_id TEXT PRIMARY KEY,
  type TEXT NOT NULL,               -- model, texture, animation, audio, fx, biome, quest, npc, prop, ui, system
  name TEXT NOT NULL,
  version TEXT NOT NULL,            -- semver
  uri TEXT NOT NULL,                -- local path or content-addressed hash
  checksum TEXT NOT NULL,
  author TEXT,                      -- handle/id
  license TEXT,                     -- SPDX or custom
  tags TEXT,                        -- comma-separated
  created_at TEXT NOT NULL,         -- ISO-8601
  updated_at TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS asset_variants (
  variant_id TEXT PRIMARY KEY,
  asset_id TEXT NOT NULL,
  lod INTEGER,                      -- level of detail
  platform TEXT,                    -- win, linux, console, mobile
  format TEXT,                      -- gltf, usd, wav, etc.
  uri TEXT NOT NULL,
  checksum TEXT NOT NULL,
  created_at TEXT NOT NULL,
  FOREIGN KEY(asset_id) REFERENCES asset_catalog(asset_id)
);

CREATE TABLE IF NOT EXISTS behavior_catalog (
  behavior_id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  domain TEXT NOT NULL,             -- ai, physics, animation, fx
  params_json TEXT NOT NULL,
  version TEXT NOT NULL,
  created_at TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS animation_catalog (
  anim_id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  rig TEXT NOT NULL,                -- humanoid, quadruped, etc.
  duration_ms INTEGER NOT NULL,
  events_json TEXT,                 -- footstep, hitframe, etc.
  version TEXT NOT NULL,
  uri TEXT NOT NULL,
  checksum TEXT NOT NULL,
  created_at TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS placements_ledger (
  event_id TEXT PRIMARY KEY,
  actor TEXT NOT NULL,              -- system id or user handle
  action TEXT NOT NULL,             -- create/update/deprecate/place/remove
  target_id TEXT NOT NULL,          -- asset_id or anim_id or behavior_id
  world_coordinate TEXT,            -- serialized vector
  seed TEXT,                        -- deterministic seed
  metadata_json TEXT NOT NULL,      -- biome, time, context flags
  approved BOOLEAN NOT NULL DEFAULT 0,
  approval_tx TEXT,                 -- wasm tx id/hash
  created_at TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_asset_type ON asset_catalog(type);
CREATE INDEX IF NOT EXISTS idx_placements_target ON placements_ledger(target_id);
