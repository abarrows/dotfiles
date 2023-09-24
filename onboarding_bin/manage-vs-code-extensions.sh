#!/bin/bash

# Define the paths to the scripts
TEAM_SCRIPT="./onboarding_bin/vscode-install-extensions-from-team.sh"
LOCAL_SCRIPT="./onboarding_bin/vscode-install-extensions-from-local.sh"

# Getting the list of installed extensions
installed_extensions=$(code --list-extensions)

# Counting the number of installed extensions
extension_count=$(echo "$installed_extensions" | wc -l)

if (($extension_count < 20)); then
    echo "Running the team script as there are less than 20 extensions..."
    bash "$TEAM_SCRIPT"
else
    echo "Running the local script as there are 20 or more extensions..."
    bash "$LOCAL_SCRIPT"
fi
