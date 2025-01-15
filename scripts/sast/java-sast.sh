#!/bin/bash
PROJECT_DIR=$1
echo "Running Java static code analysis..."
cd "$PROJECT_DIR"
mvn sonar:sonar
