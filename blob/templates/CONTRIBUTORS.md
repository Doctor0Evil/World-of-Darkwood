# Windows-of-Death Contributors

## Core Team
- **Lead Developer**: [Jacob Scott Farmer](https://github.com/Doctor0Evil)
- **Principal Contributor**: [Acid-Wizard-Studios](https://github.com/Acid-Wizard-Studios)

## AI Collaborators
| AI System | Role | Access Level |
|-----------|------|--------------|
| [Microsoft Copilot](https://github.com/features/copilot) | Code Assistance | Read-Only (Suggestions) |
| [Perplexity.Labs](https://perplexity.ai) | Security Scanning | Automated PR Comments |

## Contribution Rules
### 1. **Code Contributions**
- All PRs require **2 human approvals** (excluding bot comments).
- Changes to `registry/connectors.yml` require **3 approvals**.
- Use the `dev` branch for experimental features.

### 2. **Security Policies**
- **Do NOT** modify `agents/snowflake-agent.yml` without prior discussion.
- All asset payloads (`payloads/*.yml`) must pass Wolfman AI validation.

### 3. **AI Collaboration Guidelines**
- Microsoft Copilot may suggest code but **cannot merge**.
- Perplexity.Labs bot comments are **mandatory to address** before merging.

### 4. **Credit Policy**
- Every contributor must be listed below.
- Major contributions warrant co-authorship in release notes.

## Current Contributors
### Individual Contributors
- [Your Name](https://github.com/your-handle) - [Your Contribution]

### Organizational Contributors
- **Acid-Wizard-Studios** - Core Architecture
- **Wolfman AI** - Security Validation

## How to Add Yourself
1. Fork the repo.
2. Add your name to this file.
3. Submit a PR with your contribution.

## License
By contributing, you agree to the [MIT License](LICENSE).
