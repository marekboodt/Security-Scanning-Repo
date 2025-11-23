# ðŸ” IaC (Infrastructure as Code) Security Scanning

This repository provides **centralized, reusable GitHub Actions workflows** for automated IaC (Infrastructure as Code) security scanning.
It is designed to make security scanning easy and accessible for all developers in your organizationâ€”so "no time" or "too difficult" is no longer an excuse.

---

## ðŸ‘¤ Who Is This For?

**Any developer or team who wants to add robust security scanning to their GitHub projects with minimal setup.**
Just add a code snippet to your workflow; this repository manages everything else.

---

## ðŸš€ How It Works

You simply add a provided code snippet to your own repository's GitHub Actions workflow file.
This snippet will call the relevant workflow from this repository and run the selected security scan on your infrastructure code.

- **You select which workflow to use** by setting parameters in your workflow snippet.
- The scanning logic, tool integrations, and updates are all handled centrally in this repository.
- **The `main` branch is always stable and production-ready.** New features and updates are tested in branches before being merged to `main`, so you always get the latest working version.

---

## ðŸ› ï¸ What is IaC Scanning?

**IaC (Infrastructure as Code Security)** scans your Terraform infrastructure-as-code files for misconfigurations and security risks.

**Supported tool:** `checkov`

---

## ðŸ“ˆ Results and Artifacts

**Scan results:**  
- All findings will appear in your repository's **Security** and **Actions** tabs.  
- SARIF and other output files will be available as downloadable artifacts after the workflow run.

---

## âš¡ Quick Start

1. Copy one of the code blocks below into your repository's `.github/workflows/your-workflow.yml`.
2. Adjust the `with:` parameters as needed for your project.
3. Commit and pushâ€”scans will run automatically!

---

## ðŸ”‘ Required Secrets and Variables

<table>
  <tr>
    <th>Tool</th>
    <th>Required Secret/Variable</th>
    <th>Where to Set</th>
  </tr>
  <tr>
    <td>Checkov</td>
    <td><em>none</em></td>
    <td>-</td>
  </tr>
</table>

---

## ðŸ”’ Required Workflow Permissions

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
      <td><code>type</code></td>
      <td><code>iac</code></td>
      <td>Specifies the scan type as Infrastructure as Code.</td>
    </tr>
    <tr>
      <td><code>language</code></td>
      <td><code>terraform</code></td>
      <td>The IaC language to scan. Currently supports Terraform.</td>
    </tr>
    <tr>
      <td><code>project_dir</code></td>
      <td>Path (e.g. <code>./</code>, <code>./terraform</code>)</td>
      <td>Directory containing your IaC files.</td>
    </tr>
    <tr>
      <td><code>environment</code></td>
      <td><code>prod</code>, <code>non-prod</code></td>
      <td><code>prod</code>: blocks pipeline on findings; <code>non-prod</code>: does not block pipeline (continue-on-error).</td>
    </tr>
  </tbody>
</table>

--- 

## ðŸ§© Example Usage

Add one of the following blocks to your own repository's workflow file, and customize the parameters as needed.

### IaC Scan (GitHub Actions) - Recommended

Best to use for standard scanning needs.

```yaml
IAC-GH-Actions-Workflow:
  uses: marekboodt/Security-Scanning-Repo/.github/workflows/03-iac-github-action-workflow.yml@main
  with:
    type: iac
    language: terraform
    project_dir: ./
    environment: non-prod 
```

### IaC Scan (Custom Scan) - Advanced

Use this if you want a more fine-grained outcome.

```yaml
IAC-Custom-Workflow:
  uses: marekboodt/Security-Scanning-Repo/.github/workflows/03-iac-custom-workflow.yml@main
  with:
    type: iac
    language: terraform
    project_dir: ./
    environment: non-prod 
```

---

## âš™ï¸ Configuring Checkov (Optional)

If you want to accept certain risks or skip specific checks in your IaC scans, add a file named `.checkov.yml` to the root folder of your GitHub project.

This file allows you to configure which folders or checks to skip.

### .checkov.yml Example

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
