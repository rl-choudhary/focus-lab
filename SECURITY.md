# Security Policy

## Security & Confidentiality Rules

To ensure the safety, privacy, and integrity of this codebase, all contributors and maintainers must strictly adhere to the following rules:

### 1. Strict Prohibition of Committing Secrets & Private Credentials
**DO NOT** push or commit any of the following to Git repositories or version control:
- **Keystore files**: `*.jks`, `*.keystore`, `*.p12`, `*.pem`, `upload-keystore.jks`
- **Keystore credential details**: `keystore_details.json`, `key.properties`
- **Private keys & signing passwords**: Any plain-text passwords or secret keys.
- **Environment files**: `.env`, `.env.local`, API secret tokens.

### 2. Required Git Ignore Rules
Ensure all secret files and signing configurations are listed in `.gitignore` before committing code:
```gitignore
# Keystores & Signing Keys
key.properties
keystore_details.json
**/*.keystore
**/*.jks
*.p12
*.pem
.env
```

### 3. Immediate Action on Accidental Credential Leaks
If sensitive files (such as keystores or passwords) are accidentally committed:
1. Immediately remove the file from git tracking (`git rm --cached <file>`).
2. Add the file pattern to `.gitignore`.
3. Revoke, rotate, or re-generate the compromised credentials immediately.

---

## Reporting a Vulnerability

If you discover a security vulnerability or security breach within this repository, please report it privately:
- **Contact**: Reach out to the maintainer directly via GitHub at [https://github.com/rl-choudhary](https://github.com/rl-choudhary).
- **Process**: Please provide a description of the issue and steps to reproduce. Do not create public GitHub issues for security vulnerabilities until they have been addressed.
