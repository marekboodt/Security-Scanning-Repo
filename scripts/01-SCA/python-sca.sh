#!/bin/bash
PROJECT_DIR=$1

# Get the repository name from the GITHUB_REPOSITORY environment variable
REPO_NAME=$(basename "$GITHUB_REPOSITORY")
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
OUTPUT_FILE="${REPO_NAME}-SCA-SCAN-${TIMESTAMP}.json"

echo "Running Python dependency scan for project: $REPO_NAME ..."
cd "$PROJECT_DIR"

# Install pip-audit
pip install pip-audit

# Run pip-audit and save to the dynamically named file
pip-audit --verbose --output json > "$GITHUB_WORKSPACE/$OUTPUT_FILE" 2>&1
EXIT_CODE=$?
# Check if pip-audit ran successfully
if [ $EXIT_CODE -ne 0 ]; then
  echo "Error: pip-audit failed to execute."
  cat "$GITHUB_WORKSPACE/$OUTPUT_FILE"
  exit 1
fi

echo "Dependency scan completed. Results saved to $GITHUB_WORKSPACE/$OUTPUT_FILE ."

# Move the JSON file to the root directory for easy artifact upload
# mv "$OUTPUT_FILE" "$GITHUB_WORKSPACE/$OUTPUT_FILE"

# Save the output file path to an environment file
echo "OUTPUT_FILE=$GITHUB_WORKSPACE/$OUTPUT_FILE" >> $GITHUB_ENV
# Save the filename only to the environment file
echo "OUTPUT_FILENAME=$OUTPUT_FILE" >> $GITHUB_ENV
