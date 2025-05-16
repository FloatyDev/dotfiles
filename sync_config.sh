#!/bin/bash

# Define variables
REPO_URL="git@github.com:FloatyDev/dotfiles.git"  		 # Replace with your repository URL
TEMP_DIR="./temp"                                        # Temporary directory for the repo
TARGET_DIR="$HOME/.config"                               # Target directory where you want to sync the config folder
FOLDER_TO_SYNC=".config"                                  # Folder in the repo you want to sync

# Create a temporary directory and clone the repo
mkdir -p "$TEMP_DIR"
git clone "$REPO_URL" "$TEMP_DIR" || {
  echo "Failed to clone repository. Exiting."
  exit 1
}

# Execute rsync to synchronize the specified folder
rsync -av --progress "$TEMP_DIR/$FOLDER_TO_SYNC/" "$TARGET_DIR/" || {
  echo "rsync failed. Exiting."
  exit 1
}

# Cleanup: remove the temporary directory
rm -rf "$TEMP_DIR"

echo "Synchronization completed successfully."

