# 🔐 SAST (Static Application Security Testing) Security Scanning

This repository provides **centralized, reusable GitHub Actions workflows** for automated SAST (Static Application Security Testing).
It is designed to make security scanning easy and accessible for all developers in your organization—so "no time" or "too difficult" is no longer an excuse.

---

## 👤 Who Is This For?

**Any developer or team who wants to add robust security scanning to their GitHub projects with minimal setup.**
Just add a code snippet to your workflow; this repository manages everything else.

---

## 🚀 How It Works

You simply add a provided code snippet to your own repository's GitHub Actions workflow file.
This snippet will call the relevant workflow from this repository and run the selected security scan on your code.

- **You select which scan tool to use** by setting parameters in your workflow snippet.
- The scanning logic, tool integrations, and updates are all handled centrally in this repository.
- **The `main` branch is always stable and production-ready.** New features and updates are tested in branches before being merged to `main`, so you always get the latest working version.

---

## 🛠️ What is SAST?

**SAST (Static Application Security Testing)** analyzes your source code or binaries for vulnerabilities before running the application.

**Supported tools:** `semgrep`, `bearer`, `codeql` and `sonarqube` *(work in progress)*.

---

## 📈 Results and Artifacts

**Scan results:**  
- All findings will appear in your repository's **Security** and **Actions** tabs.  
- SARIF and other output files will be available as downloadable artifacts after the workflow run.

---

## ⚡ Quick Start

1. Copy the code block below into your repository's `.github/workflows/your-workflow.yml`.
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
    <td>Bearer, CodeQL</td>
    <td><em>none</em></td>
    <td>-</td>
  </tr>
</table>

---

## 🔒 Required Workflow Permissions

To ensure security scan results are properly uploaded and visible in your repository's Security tab, make sure to set the following permissions at the top of your main workflow YAML file:
```yaml
permissions:
  actions: read
  contents: read
  security-events: write


```

---

## ðŸ“ Parameter Reference

<table>
  <thead>
    <tr>
      <th>Variable</th>
      <th>Values</th>
      <th>Comment/Reason</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>sast-scan-tool</code></td>
      <td><code>semgrep</code>, <code>bearer</code>, <code>codeql</code>, <code>sonarqube</code> (work in progress)</td>
      <td>Select the SAST tool to use for static code analysis.</td>
    </tr>
    <tr>
      <td><code>language</code></td>
      <td>e.g. <code>python</code>, <code>javascript</code></td>
      <td>(Optional) For CodeQL, can be a comma-separated list of languages.</td>
    </tr>
    <tr>
      <td><code>project_dir</code></td>
      <td>Path (e.g. <code>./src</code>, <code>./</code>)</td>
      <td>Directory containing your source code.</td>
    </tr>
    <tr>
      <td><code>environment</code></td>
      <td><code>prod</code>, <code>non-prod</code></td>
      <td><code>prod</code>: blocks pipeline on findings; <code>non-prod</code>: does not block pipeline (continue-on-error).</td>
    </tr>
    <tr>
      <td><code>SEMGREP_APP_TOKEN</code></td>
      <td>Secret value</td>
      <td>
        Required for Semgrep scans.<br>
        Set as a <a href="https://docs.github.com/en/actions/security-guides/encrypted-secrets">GitHub Actions repository secret</a>.<br>
        If not using Semgrep, leave empty or remove.
      </td>
    </tr>
    <tr>
      <td><code>SONAR_TOKEN</code></td>
      <td>Secret value</td>
      <td>
        Required for SonarQube scans.<br>
        Set as a <a href="https://docs.github.com/en/actions/security-guides/encrypted-secrets">GitHub Actions repository secret</a>.<br>
        If not using SonarQube, leave empty or remove.
      </td>
    </tr>
    <tr>
      <td><code>SONAR_HOST_URL</code></td>
      <td>Variable value</td>
      <td>
        Required for SonarQube.<br>
        Set as a <a href="https://docs.github.com/en/actions/learn-github-actions/variables">GitHub Actions repository variable</a>.<br>
        If not using SonarQube, leave empty or remove.
      </td>
    </tr>
  </tbody>
</table>

--- 

## ðŸ§© Example Usage

Add the following block to your own repository's workflow file, and customize the parameters as needed.

### SAST Scan - Code to Add in Your Pipeline

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
