-- spectral_entity.lua
local HorrorSchema = require("horror_schema")

local SpectralEntity = {}
SpectralEntity.__index = SpectralEntity

function SpectralEntity.new(regionId, shci_override)
  local self = setmetatable({}, SpectralEntity)
  self.regionId = regionId
  self.ctx = HorrorSchema.query_spectral_context(regionId)
  self.SHCI = shci_override or (self.ctx and self.ctx.SHCI_default) or 0.5
  self.bt_state = {}
  return self
end

-- Root BT node: QueryHistoryDatabase
function SpectralEntity:bt_query_history()
  if not self.ctx then return "FAIL" end

  -- “What event to reenact?”
  if self.ctx.CIC > 0.7 then
    self.bt_state.eventArchetype = "catastrophe"
  elseif self.ctx.RRM > 0.6 then
    self.bt_state.eventArchetype = "ritual"
  elseif self.ctx.MDI > 0.5 then
    self.bt_state.eventArchetype = "legend_echo"
  else
    self.bt_state.eventArchetype = "ambient_dread"
  end

  -- Record coupling strength -> how rigidly we reenact specifics
  if self.SHCI >= 0.75 then
    self.bt_state.couplingMode = "tight"
  elseif self.SHCI <= 0.25 then
    self.bt_state.couplingMode = "loose"
  else
    self.bt_state.couplingMode = "mixed"
  end

  return "SUCCESS"
end

-- Example child nodes, using CIC/RRM/AOS/SPR/RWF/HVF/LSG
function SpectralEntity:bt_select_manifestation()
  if self.bt_state.eventArchetype == "catastrophe" and
     self.bt_state.couplingMode == "tight" then
    self.bt_state.behavior = "ReenactEvacuationSequence"
  elseif self.bt_state.eventArchetype == "ritual" then
    self.bt_state.behavior = "GuardRitualSigils"
  elseif self.ctx.SPR > 0.6 then
    self.bt_state.behavior = "FullEntityPursuit"
  else
    self.bt_state.behavior = "GlitchyEcho"
  end
  return "SUCCESS"
end

function SpectralEntity:bt_pick_spawn_point()
  local hvx, hvy = self.ctx.HVF.x, self.ctx.HVF.y
  local near_liminal = self.ctx.LSG > 0.6
  -- Use HVF to bias direction, LSG to snap to thresholds (doorways, treelines)
  self.bt_state.spawnPos = World.pick_haunt_position(self.regionId, hvx, hvy, near_liminal)
  return "SUCCESS"
end
