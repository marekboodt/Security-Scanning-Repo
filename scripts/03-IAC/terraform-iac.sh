#!/bin/bash
PROJECT_DIR=$1
ENVIRONMENT=$2  # Environment passed as an argument (e.g., prod or non-prod)

# Get the repository name from the GITHUB_REPOSITORY environment variable
REPO_NAME=$(basename "$GITHUB_REPOSITORY")
TIMESTAMP=$(date +"%Y-%m-%d_GMT_%H.%M")

# Directory to store scan results
#SCAN_RESULTS_DIR="$GITHUB_WORKSPACE/IaC-scan-results"
#mkdir -p "$SCAN_RESULTS_DIR"

# Dynamic artifact name, including environment
ARTIFACT_NAME="${REPO_NAME}-ALL-IAC-SCANS-${ENVIRONMENT}-${TIMESTAMP}"
SCAN_RESULTS_DIR="$GITHUB_WORKSPACE/$ARTIFACT_NAME"
mkdir -p "$SCAN_RESULTS_DIR"

# Define Checkov output file
CHECKOV_SINGLE_OUTPUT_FILE="${REPO_NAME}-IAC-CHECKOV-SINGLE-FILE-SCAN-${ENVIRONMENT}-${TIMESTAMP}.txt"

echo "Running Checkov scan for project: $REPO_NAME in environment: $ENVIRONMENT ..."
cd "$PROJECT_DIR"

###################
# Install Checkov #
###################
echo "Installing Checkov..."
pip install checkov

###########################
# Run Checkov Single File Output #
###########################
# Run Checkov for Terraform scanning, saving output as text
echo "Starting Checkov scan Single output file..."
checkov -d . --quiet > "$SCAN_RESULTS_DIR/$CHECKOV_SINGLE_OUTPUT_FILE"
# Verify if the output file exists and is not empty
if [ -s "$SCAN_RESULTS_DIR/$CHECKOV_SINGLE_OUTPUT_FILE" ]; then
    echo "Checkov scan completed successfully."
else
    echo "Warning: Checkov scan did not produce any results!"
    exit 1  # Exit with failure if Checkov fails
fi
echo "Checkov scan results saved to a Single Output File: $SCAN_RESULTS_DIR/$CHECKOV_SINGLE_OUTPUT_FILE"

###############################################
# Run Checkov Multiple Directory Output Files #
###############################################
# Detect all directories inside the project directory
echo "Detecting directories to scan..."
DIRECTORIES=$(find . -type d -mindepth 1 -maxdepth 1)  # Get top-level directories

if [ -z "$DIRECTORIES" ]; then
    echo "No directories found to scan!"
    exit 1
fi

# Loop through each directory and run Checkov
for DIR in $DIRECTORIES; do
    DIR_NAME=$(basename "$DIR")  # Extract only the directory name
    OUTPUT_DIRECTORY_FILE="${REPO_NAME}-IAC-CHECKOV-${DIR_NAME}-${ENVIRONMENT}-${TIMESTAMP}.txt"
    
    echo "Starting Checkov scan for directory: $DIR_NAME..."
    checkov -d "$DIR" --quiet > "$SCAN_RESULTS_DIR/$OUTPUT_DIRECTORY_FILE"

    # Verify if the output file is created and not empty
    if [ -s "$SCAN_RESULTS_DIR/$OUTPUT_DIRECTORY_FILE" ]; then
        echo "Checkov scan for $DIR_NAME completed successfully."
    else
        echo "Warning: Checkov scan for $DIR_NAME did not produce any results!"
    fi
done

echo "All Checkov scans completed. Results saved in: $SCAN_RESULTS_DIR"

##################################
# Save file paths to environment #
##################################
echo "ARTIFACT_NAME=$ARTIFACT_NAME" >> $GITHUB_ENV
echo "SCAN_RESULTS_DIR=$SCAN_RESULTS_DIR" >> $GITHUB_ENV
# echo "CHECKOV_SINGLE_OUTPUT_FILE=$SCAN_RESULTS_DIR/$CHECKOV_SINGLE_OUTPUT_FILE" >> $GITHUB_ENV
# echo "CHECKOV_FILENAME=$CHECKOV_SINGLE_OUTPUT_FILE" >> $GITHUB_ENV
