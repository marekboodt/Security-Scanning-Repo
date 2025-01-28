#!/bin/bash
PROJECT_DIR=$1

# Get the repository name from the GITHUB_REPOSITORY environment variable
REPO_NAME=$(basename "$GITHUB_REPOSITORY")
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

# Directory to store all scan results
SCAN_RESULTS_DIR="$GITHUB_WORKSPACE/scan-results"
mkdir -p "$SCAN_RESULTS_DIR"

# Set the output filename extension 
PIP_AUDIT_OUTPUT_FILE="${REPO_NAME}-PIP-AUDIT-SCAN-${TIMESTAMP}.txt"          # Text Output / Normal Output (Pip Audit)
  #PIP_AUDIT_OUTPUT_FILEE="${REPO_NAME}-SCA-SCAN-${TIMESTAMP}.json"     # JSON Output (Pip Audit)
SAFETY_OUTPUT_FILE="${REPO_NAME}-SAFETY-SCAN-${TIMESTAMP}.json"         # JSON Output for SAFETY

echo "Running Python dependency scan for project: $REPO_NAME ..."
cd "$PROJECT_DIR"

######################
# PIP-AUDIT SCANNING #
######################
echo "Starting PIP-AUDIT scan..."
# Install pip-audit
pip install pip-audit

# pip-audit -f json -o $GITHUB_WORKSPACE/$PIP_AUDIT_OUTPUT_FILE        # Json Output
# pip-audit -o $GITHUB_WORKSPACE/$PIP_AUDIT_OUTPUT_FILE                  # Normal Text Output
# echo "Dependency scan completed. Results saved to $GITHUB_WORKSPACE/$PIP_AUDIT_OUTPUT_FILE ."
pip-audit -o "$SCAN_RESULTS_DIR/$PIP_AUDIT_OUTPUT_FILE"

###################
# SAFETY SCANNING #
###################
echo "Starting SAFETY scan..."
# Install safety
pip install safety

# safety check --full-report > "$GITHUB_WORKSPACE/$SAFETY_OUTPUT_FILE"   # Run safety check and save the output
# echo "SAFETY scan completed. Results saved to $GITHUB_WORKSPACE/$SAFETY_OUTPUT_FILE."
safety check --full-report > "$SCAN_RESULTS_DIR/$SAFETY_OUTPUT_FILE"

##################################
# Save file paths to environment #
##################################
# Save the PIP Audit output file path to an environment file || 1 = file Location,  1 File = Name
# echo "PIP_AUDIT_OUTPUT_FILE=$GITHUB_WORKSPACE/$PIP_AUDIT_OUTPUT_FILE" >> $GITHUB_ENV
# echo "PIP_AUDIT_FILENAME=$PIP_AUDIT_OUTPUT_FILE" >> $GITHUB_ENV

# Save the SAFETY output file path to an environment file || 1 = file Location,  1 File = Name
# echo "SAFETY_OUTPUT_FILE=$GITHUB_WORKSPACE/$SAFETY_OUTPUT_FILE" >> $GITHUB_ENV
# echo "SAFETY_FILENAME=$SAFETY_OUTPUT_FILE" >> $GITHUB_ENV

echo "SCAN_RESULTS_DIR=$SCAN_RESULTS_DIR" >> $GITHUB_ENV
