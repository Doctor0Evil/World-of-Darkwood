---

# 📂 File Placement
```
/.github/workflows
  ├── minimal-ci-gate.yaml
  ├── compliance.yml
  ├── gamedev_pipeline.yml
  └── swarmnet-ci-gate.yml   # new
```

---

# 📝 swarmnet-ci-gate.yml

```yaml
name: Swarmnet Compliance Gate

on:
  pull_request:
    branches: [ "main" ]
  push:
    branches: [ "main" ]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repo
        uses: actions/checkout@v3

      - name: Validate .ing configs
        run: |
          echo "Checking .ing configs for compliance..."
          for f in $(find configs -name "*.ing"); do
            echo "Validating $f"
            # Must contain mode=enforced or swarmnet-mode-only
            grep -q "swarmnet-mode-only" $f || (echo "Missing swarmnet-mode-only in $f" && exit 1)
            # Must contain ETHSwarm anchor
            grep -q "ETHSwarm" $f || (echo "Missing ETHSwarm anchor in $f" && exit 1)
            # Must contain copy_protection=WindowsOfDeath
            grep -q "WindowsOfDeath" $f || (echo "Missing kernel persistence in $f" && exit 1)
          done

      - name: Validate .aii configs
        run: |
          echo "Checking .aii configs for compliance..."
          for f in $(find configs assets -name "*.aii"); do
            echo "Validating $f"
            grep -q "CONFIGURATION" $f || (echo "Missing CONFIGURATION block in $f" && exit 1)
            grep -q "DISABLE \"research_mode\"" $f || (echo "Research mode not disabled in $f" && exit 1)
            grep -q "AES-256-GCM" $f || (echo "Missing AES-256-GCM encryption in $f" && exit 1)
          done

      - name: Validate deterministic seeds
        run: |
          echo "Checking for deterministic seeds..."
          grep -R "seed" configs/ runtime/ || (echo "No deterministic seeds found" && exit 1)

      - name: Validate DID presence
        run: |
          echo "Checking for DID in admin configs..."
          grep -R "did:web5:admin" configs/ || (echo "Missing admin DID in configs" && exit 1)

      - name: Report success
        run: echo "✅ Swarmnet compliance checks passed."
```

---

# ✅ What this gate enforces
- **`.ing` configs** must declare:
  - `swarmnet-mode-only`
  - ETHSwarm anchoring
  - `copy_protection=WindowsOfDeath`
- **`.aii` configs** must:
  - Disable research mode
  - Use AES‑256‑GCM encryption
  - Contain a CONFIGURATION block
- **Deterministic seeds** must be present in configs/runtime
- **Admin DID** must be present in configs

---
