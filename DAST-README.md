# 🧪 DAST (Dynamic Application Security Testing) — OWASP ZAP

This page explains how to run DAST for web applications using OWASP ZAP via the centralized GitHub Actions workflows in this repository. DAST scans a running app from the outside—no source code required.

---

## 👤 Who Is This For?

**Any developer or team who wants to add robust security scanning to their GitHub projects with minimal setup.**
Just add a code snippet to your workflow; this repository manages everything else.

---

## 🚀 How It Works

You add a small snippet to your repository’s workflow. That snippet calls the DAST workflow here and runs OWASP ZAP against your target URL.

- **You select which scan type and tool to use** by setting parameters in your workflow snippet.
- The scanning logic, tool integrations, and updates are all handled centrally in this repository.
- **The `main` branch is always stable and production-ready.** New features and updates are tested in branches before being merged to `main`, so you always get the latest working version.

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
- SARIF and other output files will be available as downloadable artifacts after the workflow run.

---

## ⚡ Quick Start

1. Copy one of the code blocks below into your repository’s `.github/workflows/your-workflow.yml`.
2. Adjust the `with:` parameters as needed for your project and scan tool.
3. Set any required secrets or variables in your repository settings.
4. Commit and push—scans will run automatically!

---

## 🔑 Required Secrets and Variables

<table>
  <tr>
    <th>Tool</th>
    <th>Required Secret/Variable</th>
    <th>Where to Set</th>
  </tr>
  <tr>
    <td>Semgrep</td>
    <td><code>SEMGREP_APP_TOKEN</code></td>
    <td>GitHub Actions repository secret</td>
  </tr>
  <tr>
    <td>SonarQube</td>
    <td><code>SONAR_TOKEN</code></td>
    <td>GitHub Actions repository secret</td>
  </tr>
  <tr>
    <td>SonarQube</td>
    <td><code>SONAR_HOST_URL</code></td>
    <td>GitHub Actions repository variable</td>
  </tr>
  <tr>
    <td>Others</td>
    <td><em>none</em></td>
    <td>-</td>
  </tr>
</table>

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

### SAST scan - code to be added in your pipeline

```yaml
SAST-Scan: 
  uses: marekboodt/Security-Scanning-Repo/.github/workflows/02-sast-workflow.yml@main
  with:
    sast-scan-tool: semgrep 
    # language: python, javascript
    project_dir: ./src
    environment: non-prod
  secrets: 
    SEMGREP_APP_TOKEN: ${{ secrets.SEMGREP_APP_TOKEN }}
    SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
    SONAR_HOST_URL: ${{ vars.SONAR_HOST_URL }}
```

### IAC scan (GitHub Actions) - code to be added in your pipeline
Best to use. 
```yaml
IAC-GH-Actions-Workflow:
  uses: marekboodt/Security-Scanning-Repo/.github/workflows/03-iac-github-action-workflow.yml@main
  with:
    type: iac
    language: terraform
    project_dir: ./
    environment: non-prod 
```

### IAC scan (Custom Scan) - code to be added in your pipeline
if you want a more fine grained outcome
```yaml
IAC-Custom-Workflow:
  uses: marekboodt/Security-Scanning-Repo/.github/workflows/03-iac-custom-workflow.yml@main
  with:
    type: iac
    language: terraform
    project_dir: ./
    environment: non-prod 
```

> **Note for IAC scanning with Checkov:**  
> If you want to accept certain risks or skip specific checks in your IaC scans, add a file named <code>.checkov.yml</code> to the root folder of your GitHub project.  
> This file allows you to configure which folders or checks to skip.  
>  
> Example <code>.checkov.yml</code> configuration:

### .checkov.yml example 

```yaml
# Skip PATH in the Security Scanning Repo
skip-path:
  - .github/workflows/DEV/
  - .github/workflows/OLD/

# Testing to "accept" risks / vulnerabilities
skip-check:
  ## AWS ##
  - CKV_AWS_23      # Reason X: we accept the risk of S3 bucket doesn't need versioning 

  ## AZURE ##
  - CKV_AZURE_141   # Reason Y: we accept the risk ...

  ## GCP ##
  - CKV_GCP_53      # Reason Z: we accept the risk ...
```