#!/bin/bash

# if [ -z "$1" ]; then
#   echo "Please provide a  || exitfolder path to check for duplicates"
#   exit 1
# fi

# # Use the provided folder path
# folder_to_check="$1"

# # Change the directory to the one you want to check for duplicates
# cd "$folder_to_check" || {
#   echo "Folder not found"
#   exit 1
# }

# # Specify the three folders to search
# folder1="/Users/abarrows/offline-acbarrows"
# folder2="/Users/abarrows/Library/CloudStorage/OneDrive-AndrewsMcMeelUniversal/Personal/Commercial Media"

# # Iterate through each file in the directory
# for file in *; do
#   echo "Searching for duplicates of: $file"
#   # Find files with the same name in the specified folders and sort by name and modification time (newest first)
#   find "$folder1" "$folder2" "$folder3" -name "$file" -not -path "$folder_to_check/*" -printf "%f %T@ %Tc %p\n" 2>/dev/null | sort -k1,1 -k2,2rn | awk '{$1=""; $2=""; print}'
# done
