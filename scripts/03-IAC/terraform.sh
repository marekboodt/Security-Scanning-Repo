#!/bin/bash
PROJECT_DIR=$1
ENVIRONMENT=$2  # Environment passed as an argument (e.g., prod or non-prod)

# Get the repository name from the GITHUB_REPOSITORY environment variable
REPO_NAME=$(basename "$GITHUB_REPOSITORY")
TIMESTAMP=$(date +"%Y-%m-%d_GMT_%H.%M")

# Directory to store all scan results
SCAN_RESULTS_DIR="$GITHUB_WORKSPACE/IaC-scan-results"
mkdir -p "$SCAN_RESULTS_DIR"

# Dynamic artifact name, including environment
ARTIFACT_NAME="${REPO_NAME}-ALL-IAC-SCANS-${ENVIRONMENT}-${TIMESTAMP}"
echo "ARTIFACT_NAME=$ARTIFACT_NAME" >> $GITHUB_ENV

# Set the output filename
CHECKOV_OUTPUT_FILE="${REPO_NAME}-IAC-CHECKOV-SCAN-${ENVIRONMENT}-${TIMESTAMP}.json"

echo "Running Infrastructure as Code (IaC) scan for project: $REPO_NAME in environment: $ENVIRONMENT ..."
cd "$PROJECT_DIR" || exit

#######################
# Checkov IaC Scanning
#######################
echo "Starting Checkov scan..."
pip install checkov

# Run Checkov for Terraform scanning, saving output as JSON
checkov -d . --quiet --output json > "$SCAN_RESULTS_DIR/$CHECKOV_OUTPUT_FILE"

echo "Checkov scan completed. Results saved to $SCAN_RESULTS_DIR/$CHECKOV_OUTPUT_FILE."

##################################
# Save file paths to environment #
##################################
echo "SCAN_RESULTS_DIR=$SCAN_RESULTS_DIR" >> $GITHUB_ENV
echo "CHECKOV_OUTPUT_FILE=$SCAN_RESULTS_DIR/$CHECKOV_OUTPUT_FILE" >> $GITHUB_ENV
echo "CHECKOV_FILENAME=$CHECKOV_OUTPUT_FILE" >> $GITHUB_ENV
