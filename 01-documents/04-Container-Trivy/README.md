# 🔐 Container Image Security Scanning
### Reusable GitHub Actions Workflow (Trivy)

This document explains how to run **container image security scans** using **Trivy** via a **centralized, reusable GitHub Actions workflow**.

The goal is simple:

> ✅ Developers add **one job**  
> ✅ Provide image build details  
> ✅ The central workflow handles **everything else**

Container scanning analyzes **built container images** for known vulnerabilities without deploying them.

---
## 🎯 Goal

The purpose of this setup is to provide **consistent and automated container security scanning** across repositories.

All scanning logic, exception handling, and reporting are **managed centrally**, while application teams only configure:
- image name and tag,
- Docker build context,
- environment.

This keeps pipelines simple and security consistent.

---
## ✅ Quick Start (TL;DR)

To enable container scanning in your repository:

1. Add **one job** to your workflow
2. Set the image name and tag
3. Set the Dockerfile path
4. Choose the environment (`prod` or `non-prod`)
5. Commit and run the pipeline

Results will appear in:
- ✅ GitHub **Security → Code scanning**
- ✅ Workflow **artifacts**

---
## 🧰 Supported Scan Tool

This reusable workflow uses **Trivy** to scan container images and publish findings to GitHub Security.

---
## 🧩 Minimal YAML (One Job Only)

Add the following job to your workflow:
```yaml
jobs:
  container-scan:
    uses: marekboodt/Security-Scanning-Repo/.github/workflows/50-container-scan-workflow.yml@main
    with:
      image-name: my-app
      image-tag: latest
      dockerfile-path: ./
      environment: non-prod
```
---
## ⚙️ Configuration Inputs

| Input | Required | Description |
|---|---|---|
| `image-name` | ✅ | Name of the container image |
| `image-tag` | ✅ | Image tag (e.g. `latest`, `v1.0`, `${{ github.sha }}`) |
| `dockerfile-path` | ✅ | Path used to build the Docker image |
| `exception-profile` | ❌ | Optional base image exception profile (default: `none`) |
| `severity`          | ❌ | Optional severity filter (default: `HIGH,CRITICAL`)     |
| `environment` | ✅ | `prod` or `non-prod` |

### Environment behavior

- `non-prod` → findings do **not fail** the pipeline
- `prod` → intended for stricter enforcement

---
## 🔍 Tool-Specific Notes (Trivy)

- Trivy scans the built container image
- Two outputs are generated:
  - Table output (logs)
  - SARIF output (GitHub Security + artifacts)

Severity filtering is applied using the `severity` input.

---

## 🚫 Exception Handling (Trivy Ignore Files)

Trivy supports ignoring specific findings via `.trivyignore` files.

This workflow automatically merges exceptions from **three levels**, in order:

1. **Global exceptions**  
   Applied to all projects
2. **Base-image exception profile**  
   Applied when `exception-profile` is set
3. **Project-specific exceptions**  
   Defined in `.trivyignore` in the project repository

The merged ignore file is shown in the workflow logs for transparency.

---

## 📊 Results & Reporting

Container scan results are available in:

- ✅ **GitHub → Security → Code scanning** (SARIF)
- ✅ **Workflow artifacts** (SARIF download)
- ✅ **Workflow logs** (table output)

Artifacts are timestamped for traceability.

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
- Trivy installation
- Scan execution logic
- Exception merging
- SARIF upload
- Artifact naming
- Timestamp handling

All logic is versioned and maintained in the **central security repository**.

---
## ✅ Summary

- Add **one job**
- Provide image build details
- Optional exception profiles
- Centralized security logic
- Consistent container scanning across teams

Designed to be:
- ✅ Reusable
- ✅ Low maintenance
- ✅ Developer-friendly
- ✅ Enterprise-ready
