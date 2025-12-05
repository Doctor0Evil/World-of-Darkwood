# Windows-of-Death Sandbox
## Setup
```bash
git clone --recurse-submodules https://github.com/Doctor0Evil/Windows-of-Death.git
cd Windows-of-Death
```
## Usage
```powershell
# Run ALN Parser
powershell -File ./src/aln-parser/aln.ps1 ./payloads/demo.aln
```
```

---

### **🚀 Deployment Steps**
1. **Create repo**:
   ```bash
   gh repo create Windows-of-Death --public
   ```
2. **Push files**:
   ```bash
   git add .
   git commit -m "Initial scaffold"
   git push
   ```
3. **Clone with submodules**:
   ```bash
   git clone --recurse-submodules https://github.com/Doctor0Evil/Windows-of-Death.git
   ```
---
