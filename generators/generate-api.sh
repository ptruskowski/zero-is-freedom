#!/bin/bash

# Function to get value from the JSON config file or fallback to user input
get_config_value() {
    local key=$1
    local config_file=$2
    local default_value=$3

    if [ -f "$config_file" ]; then
        value=$(grep -oP "\"$key\"\s*:\s*\"[^\"]*\"" "$config_file" | sed -E "s/\"$key\"[[:space:]]*:[[:space:]]*\"([^\"]+)\"/\1/")
        if [[ -n "$value" ]]; then
            echo "$value"
        else
            echo "$default_value"
        fi
    else
        echo "$default_value"
    fi
}

# Function to set the root namespace in csproj file
set_root_namespace() {
    local project_file=$1
    local namespace=$2
    # Add RootNamespace element if not present, or modify it
    if grep -q "<RootNamespace>" "$project_file"; then
        sed -i "s|<RootNamespace>.*</RootNamespace>|<RootNamespace>$namespace</RootNamespace>|" "$project_file"
    else
        sed -i "/<Nullable>/a \ \ \ \ <RootNamespace>$namespace</RootNamespace>" "$project_file"
    fi
}

# Check if a config file is provided
while getopts "c:" opt; do
  case $opt in
    c)
      CONFIG_FILE=$OPTARG
      ;;
    *)
      echo "Usage: $0 -c <config_file>"
      exit 1
      ;;
  esac
done

# Get prefix and output directory from the config file (or fall back to user input)
PREFIX=$(get_config_value "prefix" "$CONFIG_FILE" "")
DEST_DIR=$(get_config_value "output" "$CONFIG_FILE" "")

# Validate prefix input if not using the config file
if [[ -z "$PREFIX" ]]; then
    read -p "Enter the project prefix: " PREFIX
    if [[ -z "$PREFIX" ]]; then
        echo "Error: Prefix cannot be empty."
        exit 1
    fi
fi

# Validate destination directory input if not using the config file
if [[ -z "$DEST_DIR" ]]; then
    read -p "Enter the destination directory: " DEST_DIR
    if [[ -z "$DEST_DIR" ]]; then
        echo "Error: Destination directory cannot be empty."
        exit 1
    fi
fi

rm -rf "$DEST_DIR"

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
set_root_namespace "$CORE_DIR/$CORE_DIR.csproj" "$PREFIX"

# Create the Infra project
INFRA_DIR="${PREFIX}.Infra"
echo "Creating Infra project in $DEST_DIR/$INFRA_DIR..."
mkdir "$INFRA_DIR"
dotnet new classlib -n "$INFRA_DIR" -o "$INFRA_DIR"
set_root_namespace "$INFRA_DIR/$INFRA_DIR.csproj" "$PREFIX"

# Create the Web project
WEB_DIR="${PREFIX}.Web"
echo "Creating Web API project in $DEST_DIR/$WEB_DIR..."
mkdir "$WEB_DIR"
dotnet new webapi -n "$WEB_DIR" -o "$WEB_DIR"
set_root_namespace "$WEB_DIR/$WEB_DIR.csproj" "$PREFIX"

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

# Install Entity Framework Core in Infra project
echo "Installing Entity Framework Core in the Infra project..."
dotnet add "$INFRA_DIR/$INFRA_DIR.csproj" package Microsoft.EntityFrameworkCore

# Download the .gitignore for Visual Studio/ .NET projects
echo "Downloading .gitignore for Visual Studio/ .NET projects..."
curl -o .gitignore https://raw.githubusercontent.com/github/gitignore/main/VisualStudio.gitignore

echo ".gitignore file created."

# Build the solution
echo "Building the solution..."
dotnet build "${PREFIX}.sln"

echo "Done! The solution, projects, and .gitignore have been created successfully in $DEST_DIR."
