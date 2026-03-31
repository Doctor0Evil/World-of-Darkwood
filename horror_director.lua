-- horror_director.lua
local HorrorSchema    = require("horror_schema")
local HorrorTelemetry = require("horror_telemetry")

local Director = {}

function Director.spawn_history_consistent_event(regionId)
  local targets = HorrorSchema.query_entertainment_targets(regionId)
  local obs     = HorrorTelemetry.get_observed()
  if not targets then return end

  -- Example policy: if EMD_obs < target, spawn clue-heavy but low-jump event
  if obs.EMD_obs < (targets.EMD or 0.6) then
    return Events.spawn_ambiguous_clue_drop(regionId)
  end

  -- If UEC is low but STCI is high, add mystery not threat
  if obs.UEC_obs < (targets.UEC or 0.6) and obs.STCI_obs >= (targets.STCI or 0.5) then
    return Events.spawn_distant_sound(regionId)
  end

  -- Preserve ARR: avoid fully resolving stories when ARR_obs < target
  if obs.ARR_obs < (targets.ARR or 0.7) then
    return Events.spawn_partial_explanation(regionId)
  else
    return Events.spawn_clearer_revelation(regionId)
  end
end

return Director
