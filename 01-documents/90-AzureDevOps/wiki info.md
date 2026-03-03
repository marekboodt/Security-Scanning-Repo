# Weekly Automated Advanced Security Scan (Azure DevOps)

Security scans can take several minutes to complete. Running them during work hours uses agent capacity and can slow down other pipelines. By scheduling scans at night, we keep the workday free and avoid interruptions.

This scan is an addition to your existing pipelines, not a replacement. Even when no deployment has happened for weeks, new vulnerabilities can be discovered in dependencies or libraries your project already uses. This nightly scan ensures your repository is checked automatically, every week, regardless of activity.

## What does this pipeline do?
This pipeline runs a weekly automated security scan on your repository. It includes:
- CodeQL security scanning using the security‑extended query suite
- Dependency vulnerability scanning for open‑source packages

The scan:
- Does not deploy anything
- Does not change your code
- Runs read‑only
- Is safe to run automatically
All findings are visible in Azure DevOps → Advanced Security.

## Why should you add this pipeline?
Adding this pipeline helps to:
- Detect security issues early
- Identify vulnerable dependencies
- Reduce manual security reviews
- Align with Axpo security standards 
This is the recommended baseline for all projects. The solution is:
- Simple to integrate
- Centrally maintained
- Low effort for project teams 
You only need to add one YAML file to your repository.

## Pipeline to add to your project
This is the only YAML you need to copy
```yaml
trigger: none
pr: none

schedules:
- cron: "0 2 * * 3"
  displayName: Weekly security scan
  branches:
    include:
    - <branch>
  always: true

resources:
  repositories:
  - repository: securityTemplates
    type: git
    name: AXSO-Security/AXSO-Security-Templates
    ref: refs/heads/main

extends:
  template: security-templates/advanced-security-scan.yml@securityTemplates
  parameters:
    language: csharp
```
You may adjust:
- cron (schedule)
- branch
- language (e.g. csharp,javascript,python) - IMPORTANT NO SPACES
-- Supported languages: https://codeql.github.com/docs/codeql-overview/supported-languages-and-frameworks/

## Understanding the schedule (cron) 
Example from the pipeline:
```yaml
schedules:
- cron: "0 2 * * 3"
```

|
 Position 
|
 Value 
|
 Meaning 
|
|
--------:
|
:------
|
:--------
|
|
 1 
|
`0`
|
 Minute 
|
|
 2 
|
`2`
|
 Hour (UTC) 
|
|
 3 
|
`*`
|
 Every day of the month 
|
|
 4 
|
`*`
|
 Every month 
|
|
 5 
|
`3`
|
 Day of the week (1 = Monday, 2 = Tuesday, 3 = Wednesday, 4 = Thursday, 5 = Friday, 6 = Saturday, 0 = Sunday) 
|


