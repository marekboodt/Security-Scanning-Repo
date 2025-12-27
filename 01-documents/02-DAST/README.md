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

---

### Configuration Per Mode

| Input | Container Mode | Local App Mode | External URL Mode |
|---|---|---|---|
| `dast-scan-tool` | `zap` | `zap` | `zap` |
| `environment` | `prod` / `non-prod` | `prod` / `non-prod` | `prod` / `non-prod` |
`project_dir` | `./` *(not used)* | `"./app"` | `./` *(not used)*
| `start_command` | `""` | `"npm ci && npm start"` | `""` |
| `website_target` | `"http://app:8080"` | `"http://localhost:3000"` | `"https://staging.example.com"` |
| `service_image` | `"myorg/myapp:latest"` | `""` | `""` |
| `container_port` | `8080` | `""` | `""` |
| `health_path` | `"/"` or `"/health"` | `"/"` *(not used)* | `"/"` *(not used)* |
| `env_json` | `"{}"` *(optional)* | `"{}"` | `"{}"` |
| `scan_type` | `"full" or "baseline"` | `"full" or "baseline"` | `"full" or "baseline"` |
| `cmd_options` | `"-a -j -r report_html.html -x report_xml.xml"` | same | same |

> 💡 In container mode, `website_target` is not used for scanning.  
> The scan always targets `http://localhost:<container_port>`.

---

## 📈 Scan Types

### ZAP Baseline Scan
- Spider + passive rules (optional limited active with `-a`)
- Fast (~1-2 minutes)

### ZAP Full Scan
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
