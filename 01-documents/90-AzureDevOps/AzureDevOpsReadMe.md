# Advanced Security Scan Pipelines

This repository contains two Azure DevOps YAML pipelines used for automated security scanning.

The setup consists of:
1. A **project-level pipeline** that schedules and triggers the scan
2. A **shared template** that performs the actual security scanning

---

## 1. Weekly Security Scan Pipeline

**File name:** `weekly-security-scan.yml`

This pipeline is added to an application repository.  
It schedules a weekly, read-only security scan.

### Purpose
- Runs automatically once per week
- Does not deploy anything
- Does not modify code
- Safe to run without user interaction

### Pipeline definition

```yaml
trigger: none
pr: none

schedules:
- cron: "46 13 * * 3"
  displayName: Weekly security scan
  branches:
    include:
    - azure-pass-retirement
  always: true

resources:
  repositories:
  - repository: securityTemplates
    type: git
    name: AXSO-Security/AXSO-Security-Templates
    ref: refs/heads/main

extends:
  template: security-templates/advanced-security-scan.yml@securityTemplates
  parameters:
    language: csharp
```

### Notes
- Azure DevOps schedules use **UTC time**
- This pipeline only references the shared security template
- The scan runs even if no recent code changes exist

---

## 2. Advanced Security Scan Template

**File name:** `advanced-security-scan.yml`

This template is centrally maintained and reused by multiple projects.
It performs code scanning and dependency scanning.

### What it does
- Initializes CodeQL with the **security-extended** query suite
- Builds the project when required (C#)
- Runs CodeQL analysis
- Runs dependency vulnerability scanning

### Template definition

```yaml
parameters:
- name: language
  type: string

jobs:
- job: AdvancedSecurityScan
  displayName: Advanced Security Scan

  # Cloudflare error - therefore not using the GEN-CA-TCI pool
  # pool:
  #   name: GEN-CA-TCI
  # If the Cloudflare error still exists, ubuntu-latest is used
  pool:
    vmImage: ubuntu-latest

  steps:
  - checkout: self

  # Initialize CodeQL - Security Extended
  - task: AdvancedSecurity-Codeql-Init@1
    inputs:
      languages: ${{ parameters.language }}
      querysuite: security-extended

  - ${{ if eq(parameters.language, 'csharp') }}:
    - task: DotNetCoreCLI@2
      displayName: Build
      inputs:
        command: build
        projects: '**/*.csproj'

  # CodeQL analysis
  - task: AdvancedSecurity-Codeql-Analyze@1

  # Dependency scanning
  - task: AdvancedSecurity-Dependency-Scanning@1
```

---

## Results

All findings are available in:
**Azure DevOps → Advanced Security**

This setup is the recommended baseline for Axpo projects.
