-- horror_schema.lua
local HorrorSchema = {}
local _regions = {}   -- regionId -> HorrorRegionProfile

function HorrorSchema.load_from_json(path)
  local raw = FS.readjson(path)       -- existing ALN/engine bridge
  for _, r in ipairs(raw.regions) do
    _regions[r.regionId] = r
  end
end

function HorrorSchema.get_region(regionId)
  return _regions[regionId]
end

-- Composite helpers
function HorrorSchema.compute_SPR(profile)
  -- Example: w1*CIC + w2*MDI + w3*AOS, clamped
  local spr = 0.4*profile.CIC + 0.35*profile.MDI + 0.25*profile.AOS
  if spr < 0 then spr = 0 end
  if spr > 1 then spr = 1 end
  return spr
end

-- Query used by spectral AI BT root
function HorrorSchema.query_spectral_context(regionId)
  local p = _regions[regionId]
  if not p then return nil end
  return {
    CIC  = p.CIC, MDI = p.MDI, AOS = p.AOS,
    RRM  = p.RRM, FCF = p.FCF,
    SPR  = p.SPR or HorrorSchema.compute_SPR(p),
    DET  = p.DET, HVF = p.HVF, LSG = p.LSG,
    SHCI_default = p.SHCI or 0.5
  }
end

-- Query used by “entertaining fear” optimizer
function HorrorSchema.query_entertainment_targets(regionId)
  local p = _regions[regionId]
  if not p then return nil end
  return {
    UEC = p.UEC_target,
    EMD = p.EMD_target,
    STCI = p.STCI_target,
    CDL = p.CDL_target,
    ARR = p.ARR_target
  }
end

return HorrorSchema
