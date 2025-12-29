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
    uses: marekboodt/Security-Scanning-Repo/.github/workflows/20-dast-workflow.yml@main
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

The workflow automatically selects **one** execution mode based on which inputs are set:

- **Container mode** → `service_image` and `container_port` are set
- **Local app mode** → `start_command` is set (and `service_image` is empty)
- **External URL mode** → neither `service_image` nor `start_command` is set

⚠️ Only one mode can be active at a time.

| Input | Container Mode | Local App Mode | External URL Mode |
|---|---|---|---|
| `dast-scan-tool` | `zap` | `zap` | `zap` |
| `environment` | `prod` / `non-prod` | `prod` / `non-prod` | `prod` / `non-prod` |
| `project_dir` | `./` *(not used)* | `"./app"` | `./` *(not used)* |
| `start_command` | `""` | `"npm ci && npm start"` | `""` |
| `website_target` | `"http://app:8080"` | `"http://localhost:3000"` | `"https://staging.example.com"` |
| `service_image` | `"myorg/myapp:latest"` | `""` | `""` |
| `container_port` | `8080` | *(omit)* | *(omit)* |
| `health_path` | `"/"` or `"/health"` | `"/"` *(not used)* | `"/"` *(not used)* |
| `env_json` | `"{}"` *(optional)* | `"{}"` | `"{}"` |
| `scan_type` | `"full" or "baseline"` | `"full" or "baseline"` | `"full" or "baseline"` |
| `cmd_options` | `"-a -j -r report_html.html -x report_xml.xml"` | same | same |

> 💡 In **container mode**, `website_target` is not used as the scan target.  
> The scan always runs against `http://localhost:<container_port>`.

---

## 🧩 Apps with Dependencies (e.g. Database, Multi-Container)

Some applications cannot be scanned using the reusable workflow modes described above.
This is typically the case for applications that require additional infrastructure,
such as a database or multiple tightly coupled containers.

Examples include:
- NodeGoat (requires MongoDB)
- Applications with stateful backends
- Multi-container application stacks

### Why this works differently

The reusable DAST workflow (`20-dast-workflow.yml` → `_21-dast-zap-workflow.yml`) is designed
to scan applications that are either:
- self-contained containers,
- local development servers, or
- already deployed and reachable via a URL.

Reusable workflows always run in **separate jobs**.
Because of this, they cannot access containers or processes that were started in another job.

For applications with dependencies, this means:
- The application **and its infrastructure must be started first**
- The OWASP ZAP scan must run **in the same job**
- The ZAP scan logic is therefore **hard-coded** in the workflow

This is a deliberate and unavoidable limitation of GitHub Actions,
not a limitation of the ZAP scan itself.

---

### Example: NodeGoat (Baseline + Full Scan)

The example below shows how to scan an application with a database dependency.

In this workflow:
1. The database (MongoDB) is started
2. The application (NodeGoat) is started and verified
3. A **baseline scan** is executed
4. The application is restarted to ensure a clean state
5. A **full (active) scan** is executed
6. Both reports are stored as artifacts

Only the **ZAP scan steps** are security-related.
All preceding steps are required to make the application reachable and stable
before the scan can run.

```yaml
# https://hub.docker.com/r/contrastsecuritydemo/nodegoat
name: DAST Scan - NodeGoat (Baseline + Full)

on:
  push:
    branches:
      - main
  workflow_dispatch:
  pull_request:

permissions:
  actions: read
  contents: read
  security-events: write

jobs:
  nodegoat_dast:
    runs-on: ubuntu-latest

    steps:
      - name: Create docker network
        run: docker network create zapnet

      - name: Start MongoDB
        run: docker run -d --name mongo --network zapnet mongo:6

      - name: Wait for MongoDB
        run: |
          for i in {1..30}; do
            docker exec mongo mongosh --quiet --eval "db.runCommand({ ping: 1 })" && exit 0
            sleep 2
          done
          exit 1

      - name: Start NodeGoat
        run: |
          docker run -d --name nodegoat --network zapnet -p 4000:4000 \
            -e MONGO_URI="mongodb://mongo:27017/nodegoat" \
            -e MONGODB_URI="mongodb://mongo:27017/nodegoat" \
            -e NODE_ENV=development \
            contrastsecuritydemo/nodegoat:1.3.0 \
            sh -lc 'npm start'

      - name: Wait for NodeGoat
        run: |
          for i in {1..60}; do
            curl -fsS http://localhost:4000/ && exit 0
            sleep 2
          done
          exit 1

      - name: Run ZAP Baseline Scan
        uses: zaproxy/action-baseline@v0.14.0
        with:
          target: "http://localhost:4000"
          fail_action: false
          cmd_options: "-j -r baseline_report_html.html -x baseline_report_xml.xml -l WARN"
        continue-on-error: true

      - name: Restart NodeGoat (clean state)
        run: |
          docker restart nodegoat
          sleep 10

      - name: Verify NodeGoat after restart
        run: |
          for i in {1..30}; do
            curl -fsS http://localhost:4000/ && exit 0
            sleep 2
          done
          exit 1

      - name: Run ZAP Full Scan
        uses: zaproxy/action-full-scan@v0.12.0
        with:
          target: "http://localhost:4000"
          fail_action: false
          cmd_options: "-a -j -r full_report_html.html -x full_report_xml.xml -l WARN"
        continue-on-error: true

      - name: Upload ZAP Reports
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: dast-zap-nodegoat-reports
          path: |
            baseline_report_html.html
            baseline_report_xml.xml
            full_report_html.html
            full_report_xml.xml
          if-no-files-found: ignore
```
> ⚠️ Full scans on intentionally vulnerable applications (such as NodeGoat) may produce
> a high number of warnings, network errors, or failed requests.
> This is expected behavior and indicates that the active scan is working as intended.

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
