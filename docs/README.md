# Security Scanning Repository

This repository contains reusable workflows and scripts for security scanning:
- **SCA (Software Composition Analysis):** Scans for vulnerable dependencies.
- **SAST (Static Application Security Testing):** Analyzes code for vulnerabilities.

## Usage
1. Add the following workflow to your project repository:

```yaml
name: Trigger SCA Workflow

on:
  push:
    branches:
      - main

jobs:
  trigger-sca:
    uses: org-name/security-scanning-repo/.github/workflows/sca-workflow.yml@main
    with:
      language: python
      project_dir: ./src
      environment: non-prod
```

2. Replace `python` and `./src` with your project-specific details.
