#!/bin/bash
PROJECT_DIR=$1

# Get the repository name from the GITHUB_REPOSITORY environment variable
REPO_NAME=$(basename "$GITHUB_REPOSITORY")
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
# JSON Output
#OUTPUT_FILE="${REPO_NAME}-SCA-SCAN-${TIMESTAMP}.json"
# Text Output
OUTPUT_FILE="${REPO_NAME}-SCA-SCAN-${TIMESTAMP}.txt"

echo "Running Python dependency scan for project: $REPO_NAME ..."
cd "$PROJECT_DIR"

######################
# PIP-AUDIT SCANNING #
######################
# Install pip-audit
pip install pip-audit

# Json Output
# pip-audit -f json -o $GITHUB_WORKSPACE/$OUTPUT_FILE
# Normal Text Output
pip-audit -o $GITHUB_WORKSPACE/$OUTPUT_FILE

echo "Dependency scan completed. Results saved to $GITHUB_WORKSPACE/$OUTPUT_FILE ."

# Save the output file path to an environment file
echo "OUTPUT_FILE=$GITHUB_WORKSPACE/$OUTPUT_FILE" >> $GITHUB_ENV
# Save the filename only to the environment file
echo "OUTPUT_FILENAME=$OUTPUT_FILE" >> $GITHUB_ENV

###################
# SAFETY SCANNING #
###################

