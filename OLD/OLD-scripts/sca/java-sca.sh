#!/bin/bash
PROJECT_DIR=$1
echo "Running Java dependency scan..."
cd "$PROJECT_DIR"
mvn dependency-check:check
