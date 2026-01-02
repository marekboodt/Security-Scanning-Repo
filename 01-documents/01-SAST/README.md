# 🧪 SAST (Static Application Security Testing)
### Reusable GitHub Actions Workflow

This document explains how to run **SAST scans** via a **centralized, reusable GitHub Actions workflow**.

The goal is simple:

> ✅ Developers add **one job** to their pipeline  
> ✅ Choose **one SAST tool**  
> ✅ The central workflow handles **everything else**

SAST analyzes **source code without running the application**.

---

## 🎯 Goal

The purpose of this setup is to provide **consistent static code scanning** across repositories with **minimal developer effort**.

Security logic, tooling, and reporting are **managed centrally**, while application teams only configure **high‑level inputs**.

---

## ✅ Quick Start (TL;DR)

To enable SAST in your repository:

1. Add **one job** to your workflow
2. Select a SAST tool (`semgrep`, `codeql`, or `bearer`)
3. Set the project directory
4. Commit and run the pipeline

Findings will appear in:
- ✅ GitHub **Security → Code scanning**
- ✅ Workflow **artifacts** (SARIF)

---

## 🧰 Supported SAST Tools

The reusable workflow supports the following tools:

| Tool | Type | Notes |
|---|---|---|
| **Semgrep** | Multi-language | Best results, supports SARIF, optional deep scan |
| **CodeQL** | Multi-language | Native GitHub engine, results stored in GitHub |
| **Bearer** | Multi-language | Lightweight and fast feedback |

Only **one tool** runs per workflow execution.

---

## 🧩 Minimal YAML (One Job Only)

Add the following job to your workflow:
```yaml
jobs:
  SAST:
    uses: marekboodt/Security-Scanning-Repo/.github/workflows/10-sast-workflow.yml@v1
    with:
      sast-scan-tool: semgrep
      project_dir: ./
      environment: non-prod
    secrets: inherit
```

---

## ⚙️ Configuration Inputs

| Input | Required | Description |
|---|---|---|
| `sast-scan-tool` | ✅ | `semgrep`, `codeql`, or `bearer` |
| `project_dir` | ✅ | Directory containing the source code |
| `environment` | ✅ | `prod` or `non-prod` |
| `language` | ❌ | Required for CodeQL only |

### Environment behavior

- `non-prod` → findings do **not fail** the pipeline
- `prod` → intended for stricter enforcement

---

## 🔍 Tool-Specific Notes

### Semgrep
- Fast lightweight scan by default
- Optional **deep scan** when `SEMGREP_APP_TOKEN` is provided
- SARIF uploaded to GitHub Security and artifacts

### CodeQL
- Uses GitHub’s official CodeQL action
- Native GitHub integration

### Bearer
- Lightweight static scan
- Fast feedback for common issues

---

## 🔐 Tool-Specific Secrets

Some SAST tools support enhanced scanning when additional secrets are provided.

These secrets are **optional** and only required for specific tools.

### Semgrep (Deep Scan)
Required only when using Semgrep deep scans:

- `SEMGREP_APP_TOKEN`

Example:
```yaml
jobs:
  SAST:
    uses: marekboodt/Security-Scanning-Repo/.github/workflows/10-sast-workflow.yml@v1
    with:
      sast-scan-tool: semgrep
      project_dir: ./src
      environment: non-prod
    secrets:
      SEMGREP_APP_TOKEN: ${{ secrets.SEMGREP_APP_TOKEN }}
```
### CodeQL and Bearer

- No secrets required
- You can safely use:
```yaml
secrets: inherit
```

---

## 📊 Results & Reporting

All supported tools generate **SARIF** output.

Results are available in:
- ✅ **GitHub → Security → Code scanning**
- ✅ **Workflow artifacts** (timestamped)

This enables centralized visibility and developer‑friendly triage.

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
- Tool installation
- Tool versions
- SARIF handling
- Upload to GitHub Security
- Artifact naming
- Scan orchestration

All logic lives in the **central security repository**.

---

## ✅ Summary

- Add **one job**
- Choose **one SAST tool**
- Minimal pipeline changes
- Centralized security logic
- Consistent results across teams

Designed to be:
- ✅ Reusable
- ✅ Low maintenance
- ✅ Developer-friendly
- ✅ Enterprise-ready

