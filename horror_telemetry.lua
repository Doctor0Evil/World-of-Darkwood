-- horror_telemetry.lua
local HorrorTelemetry = {}
local _state = {
  -- rolling windows per region or per session
  UEC_obs = 0.5,
  EMD_obs = 0.5,
  STCI_obs = 0.5,
  CDL_obs = 0.5,
  ARR_obs = 0.5,
}

-- Called by engine when certain behaviors are observed:
-- cautious movement, scanning, revisits = UEC; clue pickups = EMD; etc.
function HorrorTelemetry.on_player_tick(ev)
  -- ev contains: speed, direction_changes, scan_events, clue_found, etc.
  -- Update rolling stats; keep this deliberately simple here.
  if ev.scan_events > 0 or ev.revisited_ambiguous_spot then
    _state.UEC_obs = math.min(1.0, _state.UEC_obs + 0.01)
  else
    _state.UEC_obs = math.max(0.0, _state.UEC_obs - 0.005)
  end

  if ev.clue_found then
    _state.EMD_obs = math.min(1.0, _state.EMD_obs + 0.02)
  end

  if ev.safe_to_threat_transition then
    _state.STCI_obs = math.min(1.0, _state.STCI_obs + 0.03)
  end

  if ev.competing_theories_count then
    _state.CDL_obs = math.min(1.0, ev.competing_theories_count / 4.0)
  end

  if ev.mystery_resolved then
    _state.ARR_obs = math.max(0.0, _state.ARR_obs - 0.03)
  elseif ev.mystery_left_hanging then
    _state.ARR_obs = math.min(1.0, _state.ARR_obs + 0.02)
  end
end

function HorrorTelemetry.get_observed()
  return _state
end

return HorrorTelemetry
