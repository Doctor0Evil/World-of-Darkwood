---

## Address schema for vhs handles

- **Format:** vhs:<realm>:<mesh>:<lane>:<quota>:<role>:<id>
- **Segments:**
  - **realm:** Logical environment (1=prod, 2=staging, 3=dev)
  - **mesh:** Peer-mesh partition (1–9)
  - **lane:** Operational lane (1=story, 2=biomes, 3=combat, 4=assets, 5=pipeline, 6=AI aide, 7=QA, 8=net sync)
  - **quota:** Predefined throughput bucket (1=low, 2=medium, 3=high)
  - **role:** Role code (1=designer, 2=engineer, 3=artist, 4=audio, 5=pipeline, 6=netops, 7=qa, 8=ai-ops)
  - **id:** Unique sequence with leading zeros

- **Determinism:** Each handle carries a fixed seed and permitted action set to ensure reproducible output across swarmnet and Alan runtime.

---

## Eight contributor handles with routes, roles, and seeds

- **c-handle1:** vhs:1:1:1:2:1:0001  
  - **Role:** Designer (Story skeleton + hooks)  
  - **Lane:** Story  
  - **Quota:** Medium (2)  
  - **Determinism seed:** 41101  
  - **Websocket route:** ws://swarmnet.desktop/w13/story

- **c-handle2:** vhs:1:2:4:3:5:0002  
  - **Role:** Pipeline (Asset custody + delivery)  
  - **Lane:** Assets  
  - **Quota:** High (3)  
  - **Determinism seed:** 42202  
  - **Websocket route:** ws://swarmnet.desktop/w13/assets

- **c-handle3:** vhs:1:3:3:2:2:0003  
  - **Role:** Engineer (Combat kernel)  
  - **Lane:** Combat  
  - **Quota:** Medium (2)  
  - **Determinism seed:** 43303  
  - **Websocket route:** ws://swarmnet.desktop/w13/combat

- **c-handle4:** vhs:1:4:2:2:3:0004  
  - **Role:** Artist (Biomes + visuals)  
  - **Lane:** Biomes  
  - **Quota:** Medium (2)  
  - **Determinism seed:** 44404  
  - **Websocket route:** ws://swarmnet.desktop/w13/biomes

- **c-handle5:** vhs:1:5:5:3:5:0005  
  - **Role:** Pipeline (CI/CD, compliance)  
  - **Lane:** Pipeline  
  - **Quota:** High (3)  
  - **Determinism seed:** 45505  
  - **Websocket route:** ws://swarmnet.desktop/w13/pipeline

- **c-handle6:** vhs:1:6:8:1:6:0006  
  - **Role:** NetOps (Mesh sync + identity)  
  - **Lane:** Net sync  
  - **Quota:** Low (1)  
  - **Determinism seed:** 46606  
  - **Websocket route:** ws://swarmnet.desktop/w13/sync

- **c-handle7:** vhs:1:7:7:2:7:0007  
  - **Role:** QA (Verification + backout)  
  - **Lane:** QA  
  - **Quota:** Medium (2)  
  - **Determinism seed:** 47707  
  - **Websocket route:** ws://swarmnet.desktop/w13/qa

- **c-handle8:** vhs:1:8:6:2:8:0008  
  - **Role:** AI‑Ops (Visual learning aide, prompt contracts)  
  - **Lane:** AI aide  
  - **Quota:** Medium (2)  
  - **Determinism seed:** 48808  
  - **Websocket route:** ws://swarmnet.desktop/w13/ai

---
