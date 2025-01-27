#!/bin/bash
PROJECT_DIR=$1

# Get the repository name from the GITHUB_REPOSITORY environment variable
REPO_NAME=$(basename "$GITHUB_REPOSITORY")
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
OUTPUT_FILE="${REPO_NAM}.sca.${TIMESTAMP}.json"

echo "Running Python dependency scan for project: $REPO_NAME..."
cd "$PROJECT_DIR"

# Install pip-audit
pip install pip-audit

# Run pip-audit and save to the dynamically named file
pip-audit --output json > "$OUTPUT_FILE"
echo "Dependency scan completed. Results saved to $OUTPUT_FILE."

# Save the output file path to an environment file
echo "OUTPUT_FILE=$PROJECT_DIR/$OUTPUT_FILE" >> $GITHUB_ENV
