#!/bin/bash
PROJECT_DIR=$1
ENVIRONMENT=$2  # Environment passed as an argument (e.g., prod or non-prod)

# Get the repository name from the GITHUB_REPOSITORY environment variable
REPO_NAME=$(basename "$GITHUB_REPOSITORY")
TIMESTAMP=$(date +"%Y-%m-%d_GMT_%H.%M")

# Directory to store scan results
SCAN_RESULTS_DIR="$GITHUB_WORKSPACE/IaC-scan-results"
mkdir -p "$SCAN_RESULTS_DIR"

# Dynamic artifact name, including environment
ARTIFACT_NAME="${REPO_NAME}-IAC-SCANS-${ENVIRONMENT}-${TIMESTAMP}"
echo "ARTIFACT_NAME=$ARTIFACT_NAME" >> $GITHUB_ENV

# Checkov output file
CHECKOV_OUTPUT_FILE="${REPO_NAME}-IAC-CHECKOV-SCAN-${ENVIRONMENT}-${TIMESTAMP}.json"

echo "Running Checkov scan for project: $REPO_NAME in environment: $ENVIRONMENT ..."
cd "$PROJECT_DIR" || exit

#######################
# Install and Run Checkov
#######################
echo "Installing Checkov..."
pip install checkov

# Run Checkov for Terraform scanning, saving output as JSON
echo "Starting Checkov scan..."
checkov -d . --quiet --output json > "$SCAN_RESULTS_DIR/$CHECKOV_OUTPUT_FILE"

# Verify if the output file exists and is not empty
if [ -s "$SCAN_RESULTS_DIR/$CHECKOV_OUTPUT_FILE" ]; then
    echo "Checkov scan completed successfully."
else
    echo "Warning: Checkov scan did not produce any results!"
    exit 1  # Exit with failure if Checkov fails
fi

echo "Checkov scan results saved to: $SCAN_RESULTS_DIR/$CHECKOV_OUTPUT_FILE"

##################################
# Save file paths to environment #
##################################
echo "CHECKOV_OUTPUT_FILE=$SCAN_RESULTS_DIR/$CHECKOV_OUTPUT_FILE" >> $GITHUB_ENV
echo "CHECKOV_FILENAME=$CHECKOV_OUTPUT_FILE" >> $GITHUB_ENV
