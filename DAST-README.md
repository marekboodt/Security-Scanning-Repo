# 🧪 DAST (Dynamic Application Security Testing) — OWASP ZAP

This page explains how to run DAST for web applications using OWASP ZAP via the centralized GitHub Actions workflows in this repository. DAST scans a running app from the outside—no source code required.

---

## 👤 Who Is This For?

**Any developer or team who wants to add robust security scanning to their GitHub projects with minimal setup.**
Just add a code snippet to your workflow; this repository manages everything else.

---

## 🚀 How It Works

You add a small snippet to your repository’s workflow. That snippet calls the DAST workflow here and runs OWASP ZAP against your target URL.

- You provide the target URL (and optionally start your app inside the workflow).
- The workflow runs ZAP and uploads results.
- Results appear in your repository’s Security and Actions tabs; artifacts are attached to the run.

---

## ⚠️ Reuse vs Copy-Paste (Important for localhost targets)
If your target runs on localhost inside CI, keep ZAP in the same job that starts your app.

For apps started in CI (Docker, Compose, npm, Python, Java, .NET): you must copy-paste the ZAP YAML block directly into your pipeline, in the same running job/step/task that starts your app on localhost. This ensures ZAP can reach 
http://localhost:PORT

---

## 🛠️ Supported Scan Types & Tools

- **SAST (Static Application Security Testing):**  
  Analyzes your source code or binaries for vulnerabilities before running the application.  
  Supported tools: `semgrep`, `bearer`, `codeql` and `sonarqube` *(work in progress)*.

- **IaC (Infrastructure as Code Security):**  
  Scans your Terraform infrastructure-as-code files for misconfigurations and security risks.  
  Supported tool: `checkov`

---

## 📈 Results and Artifacts

**Scan results:**  
- All findings will appear in your repository’s **Security** and **Actions** tabs.  
- SARIF and other ZAP reports (HTML/JSON/Markdown) will be available as downloadable artifacts after the run.

---

## 🔒 Required Workflow Permissions

To ensure security scan results are properly uploaded and visible in your repository’s Security tab, make sure to set the following permissions at the top of your main workflow YAML file:

```yaml
permissions:
  actions: read
  contents: read
  security-events: write
```

---

## 🧩 Example Usage

Add one of the following blocks to your own repository’s workflow file, and customize the parameters as needed.

### ZAP Full scan - Full scan against a single service (generic “web-app” service)
Best scan to use, takes longer than the basic scan, but finds more. Best used not on every pipeline run.
for example best used before creating artifacts.

```yaml
jobs:
  zap_full_scan:
    runs-on: ubuntu-latest

    # Start your target application as a service container
    services:
      web-app:                        # Service name (choose any, e.g., "api" or "frontend")
        image: OWNER/IMAGE:TAG        # e.g., bkimminich/juice-shop:latest
        ports:
          - HOST_PORT:CONTAINER_PORT  # e.g., 3000:3000 to expose on localhost:3000

    steps:
      # Wait until the app is reachable to avoid scanning too early
      - name: Wait for app to be ready
        run: |
          echo "Waiting for app to start..."
          for i in {1..30}; do
            if curl -s http://localhost:HOST_PORT > /dev/null; then
              echo "App is up!"
              exit 0
            fi
            echo "Still waiting..."
            sleep 5
          done
          echo "App did not start in time"
          exit 1

      # Optional: Only needed if ZAP report writes fail due to permissions
      - name: Fix permissions for ZAP output (optional)
        run: sudo chmod -R 777 $GITHUB_WORKSPACE
        # $GITHUB_WORKSPACE is the repo's working directory path for this job

      # Full (active) scan: deeper, slower
      - name: Run ZAP Full Scan (HTML + JUnit XML)
        uses: zaproxy/action-full-scan@v0.12.0
        with:
          target: 'http://localhost:HOST_PORT'   # Must match your exposed host port
          fail_action: false                     # Flip to true to fail on findings (prod gating)
          cmd_options: '-a -x report_xml.xml -l WARN'
        continue-on-error: true                  # Keep during tuning; remove for enforcement

      # Publish reports as artifacts for download
      - name: Upload ZAP Reports
        uses: actions/upload-artifact@v4
        with:
          name: full-zap-reports
          path: |
            report_html.html
            report_json.json
            report_md.md
            report_xml.xml
        continue-on-error: true
```

### ZAP Quick Scan - Baseline scan against a single service (generic)
takes about 1-2 minutes, but finds less 
```yaml
jobs:
  zap_scan:
    runs-on: ubuntu-latest

    # Start your target application as a service container
    services:
      web-app:
        image: OWNER/IMAGE:TAG              # e.g., bkimminich/juice-shop:latest
        ports:
          - HOST_PORT:CONTAINER_PORT        # e.g., 3000:3000

    steps:
      - name: Wait for app to be ready
        run: |
          echo "Waiting for app to start..."
          for i in {1..30}; do
            if curl -s http://localhost:HOST_PORT > /dev/null; then
              echo "App is up!"
              exit 0
            fi
            echo "Still waiting..."
            sleep 5
          done
          echo "App did not start in time"
          exit 1

      # Optional: only if report writes fail due to permissions
      - name: Fix permissions for ZAP output (optional)
        run: sudo chmod -R 777 $GITHUB_WORKSPACE

      # Baseline scan is passive by default; -a enables limited active checks
      - name: Run ZAP Baseline Scan (HTML + JUnit XML)
        uses: zaproxy/action-baseline@v0.12.0
        with:
          target: 'http://localhost:HOST_PORT'
          fail_action: false
          cmd_options: '-a -x report_xml.xml'    # Remove -a for passive-only scans
        continue-on-error: true

      - name: Upload ZAP Reports
        uses: actions/upload-artifact@v4
        with:
          name: zap-reports
          path: |
            report_html.html
            report_json.json
            report_md.md
            report_xml.xml
        continue-on-error: true
```

### Zap Full Scan - With multi-container target (DB + app on custom network)

```yaml
jobs:
  zap_full_scan:
    runs-on: ubuntu-latest

    steps:
      # Use a dedicated Docker network so containers can resolve each other by name
      - name: Create docker network
        run: docker network create APP_NET         # e.g., zapnet

      # Start your database (adjust image/version)
      - name: Start database
        run: |
          docker run -d --name DB_SERVICE --network APP_NET DB_IMAGE:DB_TAG
          # e.g., docker run -d --name mongo --network zapnet mongo:6

      # Wait for the database to be ready (adjust health check command)
      - name: Wait for database to be ready
        run: |
          echo "Waiting for database..."
          for i in {1..30}; do
            # Example ping for Mongo; replace with your DB's health check
            if docker exec DB_SERVICE mongosh --quiet --eval "db.runCommand({ ping: 1 })" >/dev/null 2>&1; then
              echo "Database is ready."
              exit 0
            fi
            sleep 2
          done
          echo "Database did not start in time"
          docker logs DB_SERVICE || true
          exit 1

      # Start your application container, connected to the same network
      - name: Start application container
        run: |
          docker run -d --name APP_SERVICE --network APP_NET -p HOST_PORT:CONTAINER_PORT \
            -e APP_DB_URI="DB_SCHEME://DB_SERVICE:DB_PORT/DB_NAME" \
            -e NODE_ENV=development \
            APP_IMAGE:APP_TAG \
            sh -lc 'APP_START_COMMAND'
          # Example:
          # docker run -d --name nodegoat --network zapnet -p 4000:4000 \
          #   -e MONGODB_URI="mongodb://mongo:27017/nodegoat" \
          #   contrastsecuritydemo/nodegoat:1.3.0 \
          #   sh -lc 'npm start'

      # Optional: show recent app logs to aid debugging
      - name: Show app logs (initial)
        run: docker logs --tail=80 APP_SERVICE || true

      # Wait until the app is reachable on localhost
      - name: Wait for app to be ready
        run: |
          echo "Waiting for app to start..."
          for i in {1..60}; do
            if curl -fsS http://localhost:HOST_PORT/ >/dev/null; then
              echo "App is up!"
              exit 0
            fi
            sleep 2
          done
          echo "App did not start in time"
          docker logs APP_SERVICE || true
          exit 1

      # Full (active) scan against localhost
      - name: Run ZAP Full Scan (HTML + JUnit XML)
        uses: zaproxy/action-full-scan@v0.12.0
        with:
          target: 'http://localhost:HOST_PORT'     # Must match the -p host port exposed above
          fail_action: false
          cmd_options: '-a -x report_xml.xml -l WARN'
        continue-on-error: true

      # Publish artifacts
      - name: Upload ZAP Reports
        uses: actions/upload-artifact@v4
        with:
          name: full-zap-reports
          path: |
            report_html.html
            report_json.json
            report_md.md
            report_xml.xml
        continue-on-error: true
```

> 