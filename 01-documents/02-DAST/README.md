# 🧪 DAST (Dynamic Application Security Testing) - OWASP ZAP  
### Reusable GitHub Actions Workflow

This document explains how to run **DAST scans using OWASP ZAP** via a **centralized, reusable GitHub Actions workflow**.

The goal is simple:

> ✅ Developers add **one job** to their pipeline  
> ✅ The central workflow handles **everything else**

DAST scans a **running web application from the outside**.  
No source code access is required.

---

## ✅ Quick Start (TL;DR)

To get DAST running in your repository:

1. Copy **one job** into your workflow (example below)
2. Choose **how your app runs** (container, local app, or external URL)
3. Commit and run the pipeline

ZAP reports will be available as **workflow artifacts**.

---

## 🧠 What This Workflow Supports

This reusable workflow supports **three execution modes**, automatically selected based on inputs.

| Mode | When to use it |
|---|---|
| **Containerized app** | Your app is available as a Docker image |
| **Local app (runner)** | Your app starts via a command (Node, Java, Python, etc.) |
| **External URL** | Your app is already deployed (staging / prod) |

Only **one mode runs per pipeline**.

---

## 🧩 What Developers Need to Add (Minimal YAML)

Add **one job** to your workflow file:

```yaml
jobs:
  DAST-ZAP:
    uses: marekboodt/Security-Scanning-Repo/.github/workflows/test-20-dast-workflow.yml@main
    with:
      dast-scan-tool: zap
      environment: non-prod
      project_dir: ./
      start_command: ""
      website_target: "http://app:3000"
      service_image: "bkimminich/juice-shop:latest"
      container_port: 3000
      health_path: "/"
      env_json: "{}"
      scan_type: "full"
      cmd_options: "-a -j -r report_html.html -x report_xml.xml"
    secrets: inherit
```
> 💡 **Note:** This example shows **container mode**.  
> For other modes, see the examples below.

That is all you need to add.

---

### Configuration Per Mode

### Configuration Per Mode

| Input | Container Mode | Local App Mode | External URL Mode |
|---|---|---|---|
| `dast-scan-tool` | `zap` | `zap` | `zap` |
| `environment` | `non-prod` | `non-prod` | `non-prod` |
| `project_dir` | `./` | `"./app"` | `./` |
| `start_command` | `""` | `"npm ci && npm start"` | `""` |
| `website_target` | `"http://app:8080"` | `"http://localhost:3000"` | `"https://staging.example.com"` |
| `service_image` | `"myorg/myapp:latest"` | `""` | `""` |
| `container_port` | `8080` | `0` | `0` |
| `health_path` | `"/"` or `"/health"` | `"/"` | `"/"` |
| `env_json` | `"{}"` *(optional)* | `"{}"` | `"{}"` |
| `scan_type` | `"full"` | `"baseline"` | `"full"` |
| `cmd_options` | `"-a -j -r report_html.html -x report_xml.xml"` | same | same |


---

## 🔀 Which Mode Should I Use?

| If your app... | Set this | Leave empty |
|---|---|---|
| Is a Docker image | `service_image`, `container_port` | `start_command` |
| Starts via command | `start_command`, `project_dir` | `service_image` |
| Already deployed | `website_target` only | Both above |

⚠️ Do not mix modes.

---

## 🧠 Execution Modes Explained

### ✅ Mode 1 - Containerized Application (Recommended)

Used when `service_image` is set.

- The app is started as a **GitHub Actions service container**
- ZAP scans `http://localhost:<container_port>`

✅ Best for:
- Modern applications
- CI before deployment
- Pull requests

**Required inputs:**
- `service_image`
- `container_port`

---

### ✅  Mode 2 - Local Application (GitHub Runner)

Used when `start_command` is set and `service_image` is empty.

- The app starts as a **process inside the GitHub runner**
- ZAP scans a localhost URL

✅ Best for:
- Non-containerized apps
- Legacy services
- Framework dev servers

⚠️ "Local" **local to the GitHub runner**, not your laptop.

**Required inputs:**
- `start_command`
- `project_dir`
- `website_target`

---

### ✅ Mode 3 - External URL

Used when **neither** `service_image` nor `start_command` is set.

- No app is started
- ZAP scans the given URL directly

✅ Best for:
- Staging environments
- Periodic scans
- Post-deployment checks

**Required input:**
- `website_target`

---

## ⚙️ Input Parameters Reference

### Core Inputs

| Input | Required | Description |
|---|---|---|
| `dast-scan-tool` | ✅ | Must be `zap` |
| `environment` | ✅ | Controls fail behavior (e.g. `non-prod`) |
| `scan_type` | ❌ | `baseline` (default) or `full` |
| `cmd_options` | ❌ | Passed directly to ZAP |

---

### Container Mode Inputs

| Input | Required | Description |
|---|---|---|
| `service_image` | ✅ | Docker image to run |
| `container_port` | ✅ | Port exposed by the container |
| `health_path` | ❌ | Health endpoint (default `/`) |
| `env_json` | ❌ | JSON string with env variables |

---

### Local App Mode Inputs

| Input | Required | Description |
|---|---|---|
| `start_command` | ✅ | Command to start the app |
| `project_dir` | ✅ | Directory where command runs |
| `website_target` | ✅ | Local URL ZAP should scan |

---

### External URL Mode Inputs

| Input | Required | Description |
|---|---|---|
| `website_target` | ✅ | Deployed application URL |

---

## 📈 Scan Types

### Baseline Scan
- Spider + passive rules
- Optional limited active checks (`-a`)
- Fast (~1-2 minutes)

### Full Scan
- Active scanning
- More findings
- Slower and intrusive

✅ Use **baseline** on PRs  
✅ Use **full** before releases

---

## 📊 Results and Artifacts

- Reports are uploaded as **GitHub Actions artifacts**
- Available formats:
  - HTML
  - JSON
  - Markdown
  - XML

⚠️ **SARIF is not supported by OWASP ZAP GitHub Actions**

Artifacts can be downloaded from the workflow run.

---

## 🔐 Required Workflow Permissions

Your workflow must include:

```yaml
permissions:
  actions: read
  contents: read
  security-events: write
```

---

## 🧭­ What Is Managed Centrally?

You **do not** need to manage:
- ZAP installation
- Docker setup
- Scan orchestration
- Artifact naming
- Mode selection

All logic is centralized and versioned.

---

## ✅  Summary

- Add **one job**
- Choose **one execution mode**
- Tune scan type if needed
- Review results via artifacts

This setup is designed to be:
- ✅  Reusable
- ✅  Low maintenance
- ✅  Easy to adopt
- ✅  Consistent across teams
