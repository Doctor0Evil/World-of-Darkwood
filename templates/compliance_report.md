# 🛡 Swarmnet Compliance Report

**Run ID:** ${{ github.run_id }}  
**Commit SHA:** ${{ github.sha }}  
**Date:** ${{ github.event.head_commit.timestamp }}

---

## ✅ Passed Checks
- [ ] `.ing` configs contain `swarmnet-mode-only`
- [ ] `.ing` configs contain ETHSwarm anchor
- [ ] `.ing` configs contain `copy_protection=WindowsOfDeath`
- [ ] `.aii` configs disable research mode
- [ ] `.aii` configs use AES-256-GCM encryption
- [ ] Deterministic seeds present in configs/runtime
- [ ] Admin DID present in configs

---

## 📂 File Results

| File | Check | Status | Notes |
|------|-------|--------|-------|
| configs/mistral_admin_control.ing | swarmnet-mode-only | ✅ | Present |
| configs/mistral_admin_control.aii | research_mode disabled | ✅ | Enforced |
| configs/swarmnetModeEnforcer.ing | ETHSwarm anchor | ✅ | Logged |
| assets/asset_manifest.aii | AES-256-GCM | ❌ | Missing encryption tag |

---

## 📊 Summary
- **Total Files Checked:** 12  
- **Passed:** 11  
- **Failed:** 1  

---

## 🚨 Next Steps
- Fix failing files before merge.  
- Ensure all configs include:
  - `swarmnet-mode-only`
  - `ETHSwarm` anchor
  - `copy_protection=WindowsOfDeath`
  - AES-256-GCM encryption
  - Deterministic seeds
  - Admin DID

---

*Generated automatically by `swarmnet-ci-gate.yml`*
