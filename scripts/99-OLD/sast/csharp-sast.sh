#!/bin/bash
PROJECT_DIR=$1
echo "Running C# static code analysis..."
cd "$PROJECT_DIR"
dotnet sonarscanner begin /k:"YourProjectKey"
dotnet build
dotnet sonarscanner end
