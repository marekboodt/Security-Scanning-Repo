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

# Set output filenames
CHECKOV_OUTPUT_FILE="${REPO_NAME}-IAC-CHECKOV-SCAN-${ENVIRONMENT}-${TIMESTAMP}.json"
TERRASCAN_AWS_OUTPUT_FILE="${REPO_NAME}-IAC-TERRASCAN-AWS-${ENVIRONMENT}-${TIMESTAMP}.json"
TERRASCAN_AZURE_OUTPUT_FILE="${REPO_NAME}-IAC-TERRASCAN-AZURE-${ENVIRONMENT}-${TIMESTAMP}.json"
TERRASCAN_GCP_OUTPUT_FILE="${REPO_NAME}-IAC-TERRASCAN-GCP-${ENVIRONMENT}-${TIMESTAMP}.json"
TFLINT_OUTPUT_FILE="${REPO_NAME}-IAC-TFLINT-SCAN-${ENVIRONMENT}-${TIMESTAMP}.json"

echo "Running Infrastructure as Code (IaC) scan for project: $REPO_NAME in environment: $ENVIRONMENT ..."
cd "$PROJECT_DIR"

#######################
# Checkov IaC Scanning
#######################
echo "Starting Checkov scan..."
pip install checkov

# Run Checkov for Terraform scanning, saving output as JSON
checkov -d . --quiet --output json > "$SCAN_RESULTS_DIR/$CHECKOV_OUTPUT_FILE"

echo "Checkov scan completed. Results saved to $SCAN_RESULTS_DIR/$CHECKOV_OUTPUT_FILE."

#######################
# Install Terrascan
#######################
echo "Installing Terrascan..."
TERRASCAN_VERSION=$(curl -s "https://api.github.com/repos/tenable/terrascan/releases/latest" | jq -r ".tag_name")
TERRASCAN_URL="https://github.com/tenable/terrascan/releases/download/${TERRASCAN_VERSION}/terrascan-linux-amd64"

if [ -z "$TERRASCAN_VERSION" ] || [ "$TERRASCAN_VERSION" = "null" ]; then
  echo "Error: Failed to fetch the latest Terrascan version."
  exit 1
fi

curl -L "$TERRASCAN_URL" -o terrascan
chmod +x terrascan
sudo mv terrascan /usr/local/bin/

#######################
# Terrascan IaC Scanning
#######################
echo "Starting Terrascan scans..."
terrascan scan -t terraform -p aws -d . --json > "$SCAN_RESULTS_DIR/$TERRASCAN_AWS_OUTPUT_FILE"
echo "Terrascan AWS scan completed."

terrascan scan -t terraform -p azure -d . --json > "$SCAN_RESULTS_DIR/$TERRASCAN_AZURE_OUTPUT_FILE"
echo "Terrascan Azure scan completed."

terrascan scan -t terraform -p gcp -d . --json > "$SCAN_RESULTS_DIR/$TERRASCAN_GCP_OUTPUT_FILE"
echo "Terrascan GCP scan completed."

#######################
# TFLint Scanning
#######################
echo "Starting TFLint scan..."
curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
tflint --init
tflint -f json > "$SCAN_RESULTS_DIR/$TFLINT_OUTPUT_FILE"
echo "TFLint scan completed. Results saved to $SCAN_RESULTS_DIR/$TFLINT_OUTPUT_FILE."


##################################
# Save file paths to environment #
##################################
echo "TERRASCAN_AWS_OUTPUT_FILE=$SCAN_RESULTS_DIR/$TERRASCAN_AWS_OUTPUT_FILE" >> $GITHUB_ENV
echo "TERRASCAN_AZURE_OUTPUT_FILE=$SCAN_RESULTS_DIR/$TERRASCAN_AZURE_OUTPUT_FILE" >> $GITHUB_ENV
echo "TERRASCAN_GCP_OUTPUT_FILE=$SCAN_RESULTS_DIR/$TERRASCAN_GCP_OUTPUT_FILE" >> $GITHUB_ENV
echo "TFLINT_OUTPUT_FILE=$SCAN_RESULTS_DIR/$TFLINT_OUTPUT_FILE" >> $GITHUB_ENV
echo "TFLINT_FILENAME=$TFLINT_OUTPUT_FILE" >> $GITHUB_ENV
