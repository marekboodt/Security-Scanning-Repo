# 🔐 Security-Scanning-Repo

This repository provides **centralized, reusable GitHub Actions workflows** for automated security testing.
It is designed to make security scanning easy and accessible for all developers in your organization—so “no time” or “too difficult” is no longer an excuse.

---

## 👤 Who Is This For?

**Any developer or team who wants to add robust security scanning to their GitHub projects with minimal setup.**
Just add a code snippet to your workflow; this repository manages everything else.

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
  - Supported tool: `OWASP ZAP` *(work in progress)*

---

## 📈 Results and Artifacts

> **Scan results:**  
> - All findings will appear in your repository’s **Security** and **Actions** tabs.  
> - SARIF and other output files will be available as downloadable artifacts after the workflow run.

---

## ⚡ Quick Start

1. Copy one of the code blocks below into your repository’s `.github/workflows/your-workflow.yml`.
2. Adjust the `with:` parameters as needed for your project and scan tool.
3. Set any required secrets or variables in your repository settings.
4. Commit and push—scans will run automatically!

---

## 🔑 Required Secrets and Variables

|
 Tool      
|
 Required Secret/Variable     
|
 Where to Set                         
|
|
-----------
|
-----------------------------
|
--------------------------------------
|
|
 Semgrep   
|
`SEMGREP_APP_TOKEN`
|
 GitHub Actions repository secret     
|
|
 SonarQube 
|
`SONAR_TOKEN`
|
 GitHub Actions repository secret     
|
|
 SonarQube 
|
`SONAR_HOST_URL`
|
 GitHub Actions repository variable   
|
|
 Others    
|
_
none
_
|
-
|

---

## 🧩 Example Usage

Add one of the following blocks to your own repository’s workflow file, and customize the parameters as needed.

> **Note:**  
> - Set `SEMGREP_APP_TOKEN` and `SONAR_TOKEN` as [GitHub Actions repository secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets).  
> - Set `SONAR_HOST_URL` as a [GitHub Actions repository variable](https://docs.github.com/en/actions/learn-github-actions/variables).  
> - If you are not using Semgrep or SonarQube, you can leave these empty or remove them from your workflow.

### SAST scan - code to be added in your pipeline
```yaml
SAST-Scan:
  uses: marekboodt/Security-Scanning-Repo/.github/workflows/02-sast-workflow.yml@main
  with:
    scantool: semgrep # Options: [semgrep, sonarqube (coming soon), bearer, codeql]
    # language: python, javascript # (Optional) For CodeQL, comma-separated list
    project_dir: ./src
    environment: non-prod # options: prod, non-prod | non-prod: does not block pipeline on findings (continue-on-error); prod: blocks pipeline if findings are found
  secrets: # Set these as GitHub repository secrets or variables. If not using Semgrep or SonarQube, these can be left empty.
    SEMGREP_APP_TOKEN: ${{ secrets.SEMGREP_APP_TOKEN }}
    SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
    SONAR_HOST_URL: ${{ vars.SONAR_HOST_URL }}
```

### IAC scan (GitHub Actions) - code to be added in your pipeline
```yaml
IAC-GH-Actions-Workflow:
  uses: marekboodt/Security-Scanning-Repo/.github/workflows/03-iac-github-action-workflow.yml@main
  with:
    type: iac
    language: terraform
    project_dir: ./
    environment: non-prod # options: prod, non-prod | non-prod: does not block pipeline on findings (continue-on-error); prod: blocks pipeline if findings are found
```

### IAC scan (custom scan) - code to be added in your pipeline
```yaml
IAC-Custom-Workflow:
  uses: marekboodt/Security-Scanning-Repo/.github/workflows/03-iac-custom-workflow.yml@main
  with:
    type: iac
    language: terraform
    project_dir: ./
    environment: non-prod # options: prod, non-prod | non-prod: does not block pipeline on findings (continue-on-error); prod: blocks pipeline if findings are found
```

### DAST scan (work in progress) - code to be added in your pipeline
```yaml
DAST-Scan:
  uses: marekboodt/Security-Scanning-Repo/.github/workflows/04-dast-workflow.yml@main
  with:
    scantool: zap # Currently supported: [zap]
    project_dir: ./src
    environment: non-prod # options: prod, non-prod | non-prod: does not block pipeline on findings (continue-on-error); prod: blocks pipeline if findings are found
    start_command: python manage.py runserver
    website_target: 'http://localhost:8000'