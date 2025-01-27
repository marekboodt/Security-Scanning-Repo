#!/bin/bash
PROJECT_DIR=$1

# Generate a dynamic filename for the JSON output
PROJECT_NAME=$(basename "$PROJECT_DIR") # Get the last part of the project_dir path
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
OUTPUT_FILE="${PROJECT_NAME}.sca.${TIMESTAMP}.json"

echo "Running Python dependency scan..."
cd "$PROJECT_DIR"

pip install pip-audit
pip-audit --output json > "$OUTPUT_FILE"
echo "Dependency scan completed. Results saved to pip-audit.json."

# Print the filename for debugging purposes
echo "::set-output name=output_file::$PROJECT_DIR/$OUTPUT_FILE"
