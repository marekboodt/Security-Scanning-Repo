#!/bin/bash
PROJECT_DIR=$1
echo "1234Running Python dependency scan..."
cd "$PROJECT_DIR"
pip install pip-audit
pip-audit --output json
echo "222 Running Python dependency scan..."
pip-audit 
