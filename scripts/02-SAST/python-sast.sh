#!/bin/bash
PROJECT_DIR=$1
echo "Running Python static code analysis..."
cd "$PROJECT_DIR"
pip install bandit
bandit -r .
