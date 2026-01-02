# 🏗️ IaC (Infrastructure as Code) Security Scanning
### Reusable GitHub Actions Workflow

This document explains how to run **IaC security scans** using **Checkov** via **centralized, reusable GitHub Actions workflows**.

The goal is simple:

> ✅ Developers add **one job**  
> ✅ Choose **how the scan is executed**  
> ✅ The central workflow handles **everything else**

IaC scanning analyzes **infrastructure definitions** such as Terraform code without deploying resources.

---

## 🎯 Goal

The purpose of this setup is to provide **consistent and repeatable IaC security scanning** across repositories.

All scanning logic, tooling, and reporting are **managed centrally**, while application teams only configure:
- the IaC language,
- the project directory,
- and the target environment.

This ensures predictable results and low maintenance.

---

## ✅ Quick Start (TL;DR)

To enable IaC scanning in your repository:

1. Add **one job** to your workflow
2. Set the IaC language (e.g. `terraform`)
3. Set the project directory
4. Choose the environment (`prod` or `non-prod`)
5. Commit and run the pipeline

Results will appear in:
- ✅ GitHub **Security → Code scanning**
- ✅ Workflow **artifacts**

---

## 🧰 Supported IaC Scanning Modes

The reusable IaC setup supports **two execution modes**, both using **Checkov**.

| Mode | Description | When to use |
|---|---|---|
| **GitHub Action** | Uses the official Checkov GitHub Action | Default, simple, fast |
| **Custom Workflow** | Runs custom scripts from the security repo | Advanced use cases, more control |

Both modes:
- Use Checkov
- Generate SARIF
- Upload results to GitHub Security

---

## 🧩 Minimal YAML — GitHub Action Mode (Recommended)

This is the **default and recommended** way to run IaC scans.
```yaml
jobs:
  IAC-Scan:
    uses: marekboodt/Security-Scanning-Repo/.github/workflows/40-iac-github-action-workflow.yml@main
    with:
      language: terraform
      project_dir: ./
      environment: non-prod
```
---

## 🧩 Minimal YAML — Custom Workflow Mode

Use this mode when you need:
- custom scripts,
- extended logic,
- or non-standard Checkov execution.
```yaml
jobs:
  IAC-Custom-Scan:
    uses: marekboodt/Security-Scanning-Repo/.github/workflows/41-iac-custom-workflow.yml@main
    with:
      language: terraform
      project_dir: ./
      environment: non-prod
```

---
## ⚙️ Configuration Inputs

| Input | Required | Description |
|---|---|---|
| `language` | ✅ | IaC language (e.g. `terraform`) |
| `project_dir` | ✅ | Directory containing IaC files |
| `environment` | ✅ | `prod` or `non-prod` |

### Environment behavior

- `non-prod` → findings do **not fail** the pipeline
- `prod` → intended for stricter enforcement

---

## 🔍 Tool-Specific Notes (Checkov)

- Checkov scans all supported IaC files in the target directory
- Multiple output formats are generated:
  - CLI
  - JSON
  - SARIF
- SARIF results are uploaded to GitHub Code Scanning
- Artifacts are timestamped for traceability

### Skip Rules / Risk Acceptance

If present, a `.checkov.yml` file is respected.

This file can be used to:
- suppress known findings,
- document accepted risks,
- reduce noise.

---

## 📊 Results & Reporting

IaC scan results are available in:

- ✅ **GitHub → Security → Code scanning** (SARIF)
- ✅ **Workflow artifacts** (CLI, JSON, SARIF)

Artifacts are named using:
- language
- environment
- timestamp

This enables easy auditing and historical comparison.

---

## 🔐 Required Permissions

Your workflow must include:
```yaml
permissions:
  actions: read
  contents: read
  security-events: write
```

---

## 🧭 What Is Managed Centrally?

You **do not** manage:
- Checkov installation
- Scan execution logic
- Output formatting
- SARIF upload
- Artifact naming
- Timestamp handling

All logic is versioned and maintained in the **central security repository**.

---

## ✅ Summary

- Add **one job**
- Choose **GitHub Action or Custom mode**
- Minimal configuration
- Centralized security logic
- Consistent IaC scanning across teams

Designed to be:
- ✅ Reusable
- ✅ Low maintenance
- ✅ Transparent
- ✅ Enterprise-ready

---
