#!/bin/bash
PROJECT_DIR=$1
echo "Running Python dependency scan..."
cd "$PROJECT_DIR"
pip install pip-audit
pip-audit --output json
echo "Dependency scan completed. Results saved to pip-audit.json."

