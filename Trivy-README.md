# Security-Scanning-Repo

Centralized security scanning workflows and exception management for container images using Trivy.

## Overview

This repository provides:
- **Reusable workflow** for Trivy container scanning
- **Centralized exception management** (global and base-image specific)
- **Automated SARIF upload** to GitHub Security and Artifacts

## Usage

Call the reusable workflow from your project:

```yaml
name: Container Security Scan

on:
  push:
    branches: [ main ]
  pull_request:

permissions:
  actions: read
  contents: read
  security-events: write

jobs:
  container-scan:
    uses: marekboodt/Security-Scanning-Repo/.github/workflows/10-container-scan-workflow.yml@main
    with:
      image-name: my-app
      image-tag: latest
      dockerfile-path: ./
      exception-profile: ubuntu
      environment: non-prod
```

## Workflow Parameters

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| `image-name` | âœ… | - | Container image name |
| `image-tag` | âœ… | - | Image tag (e.g., `latest`, `v1.0`, `${{ github.sha }}`) |
| `dockerfile-path` | âœ… | - | Path to Dockerfile (e.g., `./`, `./docker`) |
| `exception-profile` | âŒ | `none` | Exception profile: `ubuntu`, `alpine`, `node`, `python`, or `none` |
| `severity` | âŒ | `HIGH,CRITICAL` | Severity levels to scan for |
| `environment` | âœ… | - | `non-prod` (continue on error) or `prod` (fail on error) |

## Exception Management

### Three-Level System

1. **Global** (`trivy-exceptions/global.trivyignore`)
   - Applied to ALL projects
   - Use for: Kernel issues, company-wide decisions, common false positives

2. **Base Image** (`trivy-exceptions/ubuntu.trivyignore`, `alpine.trivyignore`, etc.)
   - Applied when `exception-profile` is set
   - Use for: OS-specific CVEs, base image issues

3. **Project-Specific** (`.trivyignore` in project repo)
   - Applied to single project only
   - Use for: Application dependencies, temporary exceptions

### Exception Format

```
CVE-YYYY-XXXXX  # Reason | Owner/Team | Date added YYYY-MM-DD | Review/Expire Date YYYY-MM-DD
```

**Required fields:**
- **Reason**: WHY is this accepted? (short and clear)
- **Owner/Team**: Which team is responsible?
- **Date added**: When was it added?
- **Review/Expire**: When to check again? (max 6 months)

### Examples

```
# Good âœ…
CVE-2024-12345  # Feature disabled in config | Dev Team | 2024-11-23 | Review 2025-05-01
CVE-2023-99999  # express@3 - upgrade Q2 2025 | Dev Team | 2024-11-23 | Expires 2025-06-30
CVE-2024-11111  # Kernel bug - mitigated by isolation | Security | 2024-11-23 | Review 2025-03-01

# Bad âŒ
CVE-2024-12345  # TODO
CVE-2024-12345  # Accepted
CVE-2024-12345  # Will fix later
```

## Available Exception Profiles

| Profile | File | Use For |
|---------|------|---------|
| `ubuntu` | `trivy-exceptions/ubuntu.trivyignore` | Ubuntu base images (18.04, 20.04, 22.04, etc.) |
| `alpine` | `trivy-exceptions/alpine.trivyignore` | Alpine base images (musl-libc, busybox) |
| `node` | `trivy-exceptions/node.trivyignore` | Node.js base images |
| `python` | `trivy-exceptions/python.trivyignore` | Python base images |
| `none` | - | No base image exceptions |

Set in your workflow:
```yaml
with:
  exception-profile: ubuntu  # or alpine, node, python, none
```

## Adding Exceptions

### Global or Base-Image Exceptions

1. Fork this repository
2. Edit the appropriate file in `trivy-exceptions/`:
   - `global.trivyignore` - for all projects
   - `ubuntu.trivyignore` - for Ubuntu images
   - `alpine.trivyignore` - for Alpine images
3. Add CVE with proper format
4. Create Pull Request
5. Security team will review and merge

### Project-Specific Exceptions

Add to `.trivyignore` in your project repository. See [project README template](https://github.com/marekboodt/Create-Test-Container-Image/blob/main/README.md) for details.

## Repository Structure

```
Security-Scanning-Repo/
â”œâ”€â”€ .github/workflows/
â”‚   â””â”€â”€ 10-container-scan-workflow.yml    # Reusable workflow
â”œâ”€â”€ trivy-exceptions/
â”‚   â”œâ”€â”€ global.trivyignore                # Global exceptions
â”‚   â”œâ”€â”€ ubuntu.trivyignore                # Ubuntu specific
â”‚   â”œâ”€â”€ alpine.trivyignore                # Alpine specific
â”‚   â”œâ”€â”€ node.trivyignore                  # Node.js specific
â”‚   â””â”€â”€ python.trivyignore                # Python specific
â””â”€â”€ README.md
```

## How It Works

1. Your workflow calls the reusable workflow
2. Workflow checks out your project code
3. Workflow checks out this repo's `trivy-exceptions/`
4. Merges exceptions in order:
   - Global exceptions (always)
   - Base-image exceptions (if profile set)
   - Project exceptions (if `.trivyignore` exists)
5. Builds your Docker image
6. Scans image with merged exceptions
7. Uploads results:
   - Table output in logs
   - SARIF to GitHub Security tab
   - SARIF as downloadable artifact

## Results Location

- **Security Tab**: `Security â†’ Code scanning alerts` (per CVE tracking)
- **Artifacts**: Workflow run â†’ Artifacts section â†’ `trivy-results`
- **Logs**: Workflow run logs (table output)

## Troubleshooting

### CVE not being ignored

Check:
1. Is format correct? `CVE-YYYY-XXXXX  # Comment`
2. Is it in the right file? (global/profile/project)
3. Is `exception-profile` set correctly?
4. Check "Merged trivyignore file" output in workflow logs

### No Security alerts

Ensure workflow has permissions:
```yaml
permissions:
  actions: read
  contents: read
  security-events: write
```

### Permission errors

Add `actions: read` permission to your calling workflow.

## Best Practices

### âœ… DO
- Add clear reason WHY you accept a CVE
- Set realistic review dates (max 6 months)
- Use `Expires` for temporary exceptions
- Review exceptions monthly
- Remove exceptions when CVE is patched

### âŒ DON'T
- Add exceptions without proper reason
- Use "TODO" or "fix later"
- Forget to set review dates
- Add project-specific issues to global
- Accept all CVEs blindly

## Exception Review Process

### Monthly Review
1. Check all items with past review dates
2. Remove if CVE is patched
3. Extend if still valid (max 6 months)
4. Update reason if situation changed

### Adding New Exception
1. Check if already exists in global/base-image
2. Try to fix first (always preferred!)
3. Add with proper documentation
4. Create PR with justification
5. Security team reviews and approves

## Questions & Support

- **Issues**: Create issue in this repository
- **Security Team**: security-team@company.com
- **Platform Team**: platform-team@company.com

## Related Resources

- [Trivy Documentation](https://trivy.dev/)
- [GitHub Code Scanning](https://docs.github.com/en/code-security/code-scanning)
- [Example Project](https://github.com/marekboodt/Create-Test-Container-Image)
- [Trivy Ignore Files](https://aquasecurity.github.io/trivy/latest/docs/configuration/filtering/)
