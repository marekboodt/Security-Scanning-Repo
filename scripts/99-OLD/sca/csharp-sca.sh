#!/bin/bash
PROJECT_DIR=$1
echo "Running C# dependency scan..."
cd "$PROJECT_DIR"
dotnet list package --vulnerable
