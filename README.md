# 🔐 Security-Scanning-Repo

This repository provides **centralized, reusable GitHub Actions workflows** for automated security testing.
It is designed to make security scanning easy and accessible for all developers in your organization—so “no time” or “too difficult” is no longer an excuse.

---

## 👤 Who Is This For?

**Any developer or team who wants to add robust security scanning to their GitHub projects with minimal setup.**
All you need to do is add a small code snippet to your workflow; everything else is managed for you.

---

## 🚀 How It Works

You simply add a provided code snippet to your own repository’s GitHub Actions workflow file.
This snippet will call the relevant workflow from this repository and run the selected security scan on your code.

- **You select which scan type and tool to use** by setting parameters in your workflow snippet.
- The scanning logic, tool integrations, and updates are all handled centrally in this repository.
- **The `main` branch is always stable and production-ready.** New features and updates are tested in branches before being merged to `main`, so you always get the latest working version.

---

## 🛠️ Supported Scan Types & Tools

- **SAST (Static Application Security Testing):**
  - Supported tools: `semgrep`, `sonarqube` *(coming soon)*, `bearer`, `codeql`
- **IaC (Infrastructure as Code Security):**
  - Supported tool: `checkov`
- **DAST (Dynamic Application Security Testing):**
  - Supported tool: `OWASP ZAP` *(coming soon)*

---

## 📈 Results and Artifacts

- **All scan results are output in SARIF format** and are visible in your repository’s Security tab and Actions tab.
- **SARIF files** can be downloaded as artifacts.
- For custom IaC scans, you will also receive:
  - SARIF
  - JSON
  - Plain text results (from Checkov)

---

## 🧩 Example Usage

Add one of the following blocks to your own repository’s workflow file, and customize the parameters as needed.

### SAST scan - code to be added in your pipeline
```yaml
SAST-Scan:
  uses: marekboodt/Security-Scanning-Repo/.github/workflows/02-sast-workflow.yml@main
  with:
    scantool: semgrep # Options: [semgrep, sonarqube (coming soon), bearer, codeql]
    # language: python, javascript # (Optional) For CodeQL, comma-separated list
    project_dir: ./src
    environment: non-prod
  secrets:
    SEMGREP_APP_TOKEN: ${{ secrets.SEMGREP_APP_TOKEN }}
    SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
    SONAR_HOST_URL: ${{ vars.SONAR_HOST_URL }}

### IAC scan (GitHub Actions) - code to be added in your pipeline
```yaml
IAC-GH-Actions-Workflow:
  uses: marekboodt/Security-Scanning-Repo/.github/workflows/03-iac-github-action-workflow.yml@main
  with:
    type: iac
    language: terraform
    project_dir: ./
    environment: non-prod

### IAC scan (custom scan) - code to be added in your pipeline
```yaml
IAC-Custom-Workflow:
  uses: marekboodt/Security-Scanning-Repo/.github/workflows/03-iac-custom-workflow.yml@main
  with:
    type: iac
    language: terraform
    project_dir: ./
    environment: non-prod

### DAST scan - code to be added in your pipeline
```yaml
DAST-Scan:
  uses: marekboodt/Security-Scanning-Repo/.github/workflows/04-dast-workflow.yml@main
  with:
    scantool: zap # Currently supported: [zap]
    project_dir: ./src
    environment: non-prod
    start_command: python manage.py runserver
    website_target: 'http://localhost:8000'