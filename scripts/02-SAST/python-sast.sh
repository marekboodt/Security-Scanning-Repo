#!/bin/bash
PROJECT_DIR=$1

# Get the repository name from the GITHUB_REPOSITORY environment variable
REPO_NAME=$(basename "$GITHUB_REPOSITORY")
TIMESTAMP=$(date +"%Y-%m-%d_GMT_%H.%M")

# Directory to store all scan results
SCAN_RESULTS_DIR="$GITHUB_WORKSPACE/sast-results"
mkdir -p "$SCAN_RESULTS_DIR"

# Dynamic artifact name
ARTIFACT_NAME="${REPO_NAME}-ALL-SAST-SCANS-${TIMESTAMP}"
echo "ARTIFACT_NAME=$ARTIFACT_NAME" >> $GITHUB_ENV

# Set output filename
BANDIT_OUTPUT_FILE="${REPO_NAME}-SAST-BANDIT-SCAN-${TIMESTAMP}.json"

echo "Running Python static code analysis for project: $REPO_NAME ..."
cd "$PROJECT_DIR" || exit

#######################
# Bandit Static Analysis
#######################
echo "Starting Bandit scan..."
pip install bandit
bandit -r . -f json -o "$SCAN_RESULTS_DIR/$BANDIT_OUTPUT_FILE"
echo "Bandit scan completed. Results saved to $SCAN_RESULTS_DIR/$BANDIT_OUTPUT_FILE."

##################################
# Save file paths to environment #
##################################
echo "SCAN_RESULTS_DIR=$SCAN_RESULTS_DIR" >> $GITHUB_ENV
echo "BANDIT_OUTPUT_FILE=$SCAN_RESULTS_DIR/$BANDIT_OUTPUT_FILE" >> $GITHUB_ENV
echo "BANDIT_FILENAME=$BANDIT_OUTPUT_FILE" >> $GITHUB_ENV
