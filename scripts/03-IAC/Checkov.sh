#!/bin/bash

PROJECT_DIR=$1
ENVIRONMENT=$2  # prod or non-prod

# Get repository name and timestamp
REPO_NAME=$(basename "$GITHUB_REPOSITORY")
TIMESTAMP=$(date +"%Y-%m-%d_GMT_%H.%M")

# Result directory
SCAN_RESULTS_DIR="$GITHUB_WORKSPACE/Checkov-scan-results"
mkdir -p "$SCAN_RESULTS_DIR"

# Dynamic artifact name
ARTIFACT_NAME="${REPO_NAME}-${ENVIRONMENT}-ALL-CHECKOV-SCANS-${TIMESTAMP}"
echo "ARTIFACT_NAME=$ARTIFACT_NAME" >> $GITHUB_ENV

# File name for Checkov scan output
CHECKOV_OUTPUT_FILE="${REPO_NAME}-${ENVIRONMENT}-CHECKOV-SCAN-${TIMESTAMP}.xml"

echo "Running Checkov scan for project: $REPO_NAME ..."
cd "$PROJECT_DIR"

# Install Checkov
pip install --quiet checkov

###################
# Run Checkov Scan
###################
checkov \
  --directory . \
  --config-file ../terraform_yaml_pipeline_templates/.azuredevops/checkov/.checkov.yml \
  --soft-fail \
  --output junitxml \
  --output-file-path "$SCAN_RESULTS_DIR/$CHECKOV_OUTPUT_FILE"

echo "Checkov scan completed. Results saved to $SCAN_RESULTS_DIR/$CHECKOV_OUTPUT_FILE"

# Save to GitHub environment
echo "SCAN_RESULTS_DIR=$SCAN_RESULTS_DIR" >> $GITHUB_ENV
echo "CHECKOV_FILENAME=$CHECKOV_OUTPUT_FILE" >> $GITHUB_ENV
