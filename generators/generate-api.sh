#!/bin/bash

# Ask the user for the prefix
read -p "Enter the project prefix: " PREFIX

# Validate prefix input
if [[ -z "$PREFIX" ]]; then
    echo "Error: Prefix cannot be empty."
    exit 1
fi

# Ask the user for the destination directory
read -p "Enter the destination directory: " DEST_DIR

# Validate destination directory input
if [[ -z "$DEST_DIR" ]]; then
    echo "Error: Destination directory cannot be empty."
    exit 1
fi

# Ensure the destination directory exists
mkdir -p "$DEST_DIR"

# Navigate to the destination directory
cd "$DEST_DIR" || exit 1

# Create the solution
echo "Creating solution ${PREFIX}.sln in $DEST_DIR..."
dotnet new sln -n "$PREFIX"

# Create the Core project
CORE_DIR="${PREFIX}.Core"
echo "Creating Core project in $DEST_DIR/$CORE_DIR..."
mkdir "$CORE_DIR"
dotnet new classlib -n "$CORE_DIR" -o "$CORE_DIR"

# Create the Infra project
INFRA_DIR="${PREFIX}.Infra"
echo "Creating Infra project in $DEST_DIR/$INFRA_DIR..."
mkdir "$INFRA_DIR"
dotnet new classlib -n "$INFRA_DIR" -o "$INFRA_DIR"

# Create the Web project
WEB_DIR="${PREFIX}.Web"
echo "Creating Web API project in $DEST_DIR/$WEB_DIR..."
mkdir "$WEB_DIR"
dotnet new webapi -n "$WEB_DIR" -o "$WEB_DIR"

# Add projects to the solution
echo "Adding projects to solution..."
dotnet sln "${PREFIX}.sln" add "$CORE_DIR/$CORE_DIR.csproj"
dotnet sln "${PREFIX}.sln" add "$INFRA_DIR/$INFRA_DIR.csproj"
dotnet sln "${PREFIX}.sln" add "$WEB_DIR/$WEB_DIR.csproj"

# Set up project dependencies
echo "Setting up project dependencies..."
dotnet add "$INFRA_DIR/$INFRA_DIR.csproj" reference "$CORE_DIR/$CORE_DIR.csproj"
dotnet add "$WEB_DIR/$WEB_DIR.csproj" reference "$CORE_DIR/$CORE_DIR.csproj"
dotnet add "$WEB_DIR/$WEB_DIR.csproj" reference "$INFRA_DIR/$INFRA_DIR.csproj"

# Download the .gitignore for Visual Studio/ .NET projects
echo "Downloading .gitignore for Visual Studio/ .NET projects..."
curl -o .gitignore https://raw.githubusercontent.com/github/gitignore/main/VisualStudio.gitignore

echo ".gitignore file created."

# Build the solution
echo "Building the solution..."
dotnet build "${PREFIX}.sln"

echo "Done! The solution and projects have been created successfully in $DEST_DIR."
