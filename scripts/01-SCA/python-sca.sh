#!/bin/bash
PROJECT_DIR=$1

# Generate a dynamic filename for the JSON output
PROJECT_NAME=$(basename "$PROJECT_DIR") # Get the last part of the project_dir path
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
OUTPUT_FILE="${PROJECT_NAME}.sca.${TIMESTAMP}.json"

echo "Running Python dependency scan..."
cd "$PROJECT_DIR" || exit

# Install pip-audit
pip install pip-audit

# Run pip-audit and save to the dynamically named file
pip-audit --output json > "$OUTPUT_FILE"
echo "Dependency scan completed. Results saved to $OUTPUT_FILE."

# Save the output file path to an environment file
echo "OUTPUT_FILE=$PROJECT_DIR/$OUTPUT_FILE" >> $GITHUB_ENV
