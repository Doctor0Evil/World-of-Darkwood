-- File: Scripts/horror_invariants.lua
-- PURPOSE: Single source of truth for 16+ horror invariants.
-- Context is a table: { region_id=..., tile_id=..., player_state=..., time_of_day=..., contamination=..., mood=..., history=... }

local H = {}

local function clamp01(x)
    if x < 0 then return 0 end
    if x > 1 then return 1 end
    return x
end

-- Helper: sample history weights safely
local function hw(ctx, key, default)
    if ctx.history and ctx.history[key] ~= nil then return ctx.history[key] end
    return default or 0.0
end

-- 1. Catastrophic Imprint Coefficient
function H.CIC(ctx)
    return clamp01(hw(ctx, "CIC", 0.0))
end

-- 2. Mythic Density Index
function H.MDI(ctx)
    return clamp01(hw(ctx, "MDI", 0.0))
end

-- 3. Archival Opacity Score
function H.AOS(ctx)
    return clamp01(hw(ctx, "AOS", 0.0))
end

-- 4. Liminal Stress Gradient
function H.LSG(ctx)
    return clamp01(hw(ctx, "LSG", 0.0))
end

-- 5. Spectral Plausibility Rating
function H.SPR(ctx)
    local cic = H.CIC(ctx)
    local mdi = H.MDI(ctx)
    local aos = H.AOS(ctx)
    local base = 0.4 * cic + 0.35 * mdi + 0.25 * aos
    return clamp01(base)
end

-- 6. Ritual Residue Map (local strength)
function H.RRM(ctx)
    return clamp01(hw(ctx, "RRM", 0.0))
end

-- 7. Folkloric Convergence Factor
function H.FCF(ctx)
    return clamp01(hw(ctx, "FCF", 0.0))
end

-- 8. Reliability Weighting Factor (aggregate)
function H.RWF(ctx)
    return clamp01(hw(ctx, "RWF", 0.5))
end

-- 9. Dread Exposure Threshold (inverse: lower threshold -> higher danger)
function H.DET(ctx)
    return clamp01(hw(ctx, "DET", 0.5))
end

-- 10. Haunt Vector Field magnitude (0..1) – assume precomputed per tile
function H.HVF(ctx)
    return clamp01(hw(ctx, "HVF", 0.0))
end

-- 11. Spectral-History Coupling Index
function H.SHCI(ctx)
    -- Strong when spectral plausibility and ritual residue and convergence are all high.
    local spr = H.SPR(ctx)
    local rrm = H.RRM(ctx)
    local fcf = H.FCF(ctx)
    local base = (spr + rrm + fcf) / 3.0
    return clamp01(base)
end

-- ENTERTAINMENT METRICS (derived partially from runtime)

-- expects ctx.telemetry = { cautious_movement, scan_time, backtracking, etc. } (0..1)
local function tw(ctx, key, default)
    if ctx.telemetry and ctx.telemetry[key] ~= nil then return ctx.telemetry[key] end
    return default or 0.0
end

-- 12. Uncertainty Engagement Coefficient
function H.UEC(ctx)
    local cautious = tw(ctx, "cautious_movement", 0.0)
    local scanning = tw(ctx, "camera_scanning", 0.0)
    local backtrack = tw(ctx, "voluntary_backtracking", 0.0)
    local base = (cautious + scanning + backtrack) / 3.0
    return clamp01(base)
end

-- 13. Evidential Mystery Density
function H.EMD(ctx)
    -- mix of history richness and recent clue interactions
    local mdi = H.MDI(ctx)
    local clues = tw(ctx, "clue_interactions", 0.0)
    local unresolved = tw(ctx, "unresolved_threads", 0.0)
    local base = 0.4 * mdi + 0.3 * clues + 0.3 * unresolved
    return clamp01(base)
end

-- 14. Safe-Threat Contrast Index
function H.STCI(ctx)
    return clamp01(tw(ctx, "safe_threat_contrast", 0.0))
end

-- 15. Cognitive Dissonance Load
function H.CDL(ctx)
    -- how many plausible explanations are currently tracked (normalized)
    return clamp01(tw(ctx, "explanation_count_norm", 0.0))
end

-- 16. Ambiguous Resolution Ratio
function H.ARR(ctx)
    return clamp01(tw(ctx, "ambiguous_resolutions_ratio", 0.0))
end

-- Bundle all invariants in one call
function H.sample_all(ctx)
    local v = {
        CIC  = H.CIC(ctx),
        MDI  = H.MDI(ctx),
        AOS  = H.AOS(ctx),
        LSG  = H.LSG(ctx),
        SPR  = H.SPR(ctx),
        RRM  = H.RRM(ctx),
        FCF  = H.FCF(ctx),
        RWF  = H.RWF(ctx),
        DET  = H.DET(ctx),
        HVF  = H.HVF(ctx),
        SHCI = H.SHCI(ctx),
        UEC  = H.UEC(ctx),
        EMD  = H.EMD(ctx),
        STCI = H.STCI(ctx),
        CDL  = H.CDL(ctx),
        ARR  = H.ARR(ctx),
    }
    return v
end

return H
