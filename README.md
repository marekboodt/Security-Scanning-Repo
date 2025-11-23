# ðŸ” Security-Scanning-Repo

This repository provides **centralized, reusable GitHub Actions workflows** for automated security testing.
It is designed to make security scanning easy and accessible for all developers in your organizationâ€”so "no time" or "too difficult" is no longer an excuse.

---

## ðŸ‘¤ Who Is This For?

**Any developer or team who wants to add robust security scanning to their GitHub projects with minimal setup.**
Just add a code snippet to your workflow; this repository manages everything else.

---

## ðŸš€ How It Works

You simply add a provided code snippet to your own repository's GitHub Actions workflow file.
This snippet will call the relevant workflow from this repository and run the selected security scan on your code.

- **You select which scan type and tool to use** by setting parameters in your workflow snippet.
- The scanning logic, tool integrations, and updates are all handled centrally in this repository.
- **The `main` branch is always stable and production-ready.** New features and updates are tested in branches before being merged to `main`, so you always get the latest working version.

---

## ðŸ› ï¸ Supported Scan Types

| Scan Type | Description | Guide |
|-----------|-------------|-------|
| **SAST** | Static Application Security Testing - Analyzes source code for vulnerabilities | [SAST Guide](01-documents/01-SAST/SAST-README.md) |
| **DAST** | Dynamic Application Security Testing - Tests running applications | [DAST Guide](01-documents/02-DAST/DAST-README.md) |
| **IaC** | Infrastructure as Code Security - Scans Terraform for misconfigurations | [IaC Guide](01-documents/03-IAC/IAC-README.md) |
| **Container** | Container Image Security - Scans Docker images with Trivy | [Container Scanning Guide](01-documents/04-Trivy-container/Trivy-README.md)|

---

## âš¡ Quick Start

1. Choose the scan type you need from the guides above
2. Copy the code snippet from the relevant guide
3. Add it to your repository's `.github/workflows/security.yml`
4. Set any required secrets (see guide for details)
5. Commit and pushâ€”scans will run automatically!

---

## ðŸ”’ Required Workflow Permissions

To ensure security scan results are properly uploaded and visible in your repository's Security tab, add these permissions to your workflow:

```yaml
permissions:
  actions: read
  contents: read
  security-events: write
```

---

## ðŸ“ˆ Results and Artifacts

**Scan results:**  
- All findings appear in your repository's **Security** tab
- Detailed logs available in the **Actions** tab
- SARIF and other output files available as downloadable artifacts

---

## ðŸ“š Detailed Documentation

- **[SAST Guide](docs/SAST-README.md)** - Static code analysis with Semgrep, Bearer, CodeQL
- **[DAST Guide](docs/DAST-README.md)** - Dynamic testing with OWASP ZAP
- **[IaC Guide](docs/IAC-README.md)** - Infrastructure scanning with Checkov
- **[Container Guide](docs/CONTAINER-README.md)** - Docker image scanning with Trivy

---

## ðŸ”‘ Required Secrets Overview

| Tool | Required Secret/Variable | Type |
|------|-------------------------|------|
| Semgrep | `SEMGREP_APP_TOKEN` | Secret |
| SonarQube | `SONAR_TOKEN` | Secret |
| SonarQube | `SONAR_HOST_URL` | Variable |
| Bearer, CodeQL, Checkov, ZAP, Trivy | *none* | - |

See individual guides for detailed setup instructions.

---