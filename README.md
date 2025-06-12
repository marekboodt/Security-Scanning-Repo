# 🔐 Security-Scanning-Repo

This repository contains reusable workflows, configuration templates, and scripts for **automated security scanning** across software projects.

It is designed to support multiple types of scanning, including:

- **SCA**: Software Composition Analysis (dependency scanning)
- **SAST**: Static Application Security Testing (source code vulnerability scanning)
- **IaC**: Infrastructure as Code security scanning (e.g., Terraform, CloudFormation)
- **DAST** *(planned)*: Dynamic Application Security Testing (e.g., OWASP ZAP, penetration testing)

---

## 📁 Repository Structure

```bash
.github/workflows/             # Reusable GitHub Actions workflows
  ├── iac-workflow.yml         # IaC scan reusable workflow
  ├── sast-workflow.yml        # SAST reusable workflow
  ├── sca-workflow.yml         # SCA reusable workflow
  └── other templates...

scripts/                       # Execution logic for each scan type
  ├── 01-SCA/
  │   └── python-sca.sh
  ├── 02-SAST/
  │   ├── python-sast.sh
  │   └── Test_Bandit_Repo_Location
  └── 03-IAC/
      ├── terraform-iac.sh
      └── Checkov.sh

configs/                       # Optional: central config templates
docs/                          # Optional: documentation or guidance
environments/                  # Optional: environment-specific data
sast/, sca/, test/             # Optional supporting directories
README.md                      # You are here
