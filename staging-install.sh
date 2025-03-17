#!/bin/bash

echo "🔄 WordPress Staging Installation Script"
echo "This script automates creating a staging site."

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
CONFIG_FILE="${1:-$SCRIPT_DIR/staging-install.conf}"

if [[ -f "$CONFIG_FILE" ]]; then
    echo "🔹 Using configuration file: $CONFIG_FILE"
    source "$CONFIG_FILE"
else
    echo "⚠️ No configuration file found. Using default settings or prompting for input."
fi

LOGFILE="/var/log/staging-install_$(whoami)_$(date +'%Y%m%d_%H%M%S').log"

log_action() {
  local time_stamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo "$time_stamp: $1: $2" | sudo tee -a "$LOGFILE" > /dev/null
}

check_blank() {
  local value="$1"
  local var_name="$2"

  if [[ -z "$value" ]]; then
    echo "❌ Error: $var_name cannot be blank."
    log_action "Error" "$var_name cannot be blank."
    exit 1
  else
    echo "✅ $var_name is set to: $value"
  fi
}

if ! which wp > /dev/null; then
  errormsg="❌ WP CLI could not be found. Please install WP-CLI before running this script."
  echo "$errormsg"
  echo "ℹ️ For installation instructions, visit: https://wp-cli.org/#installing"
  log_action "ERROR" "$errormsg"
  exit 1
fi

# Ensure config values are loaded or prompt if missing
web_root="${WEB_ROOT:-$(read -p "📂 Enter the web root directory: " tmp && echo "$tmp")}"
check_blank "$web_root" "Web Root"

folder_name="${FOLDER_NAME:-$(read -p "📂 Enter the source folder name: " tmp && echo "$tmp")}"
check_blank "$folder_name" "Source Folder Name"

backup_file="${BACKUP_FILE:-$(read -p "📂 Enter the backup file path: " tmp && echo "$tmp")}"
check_blank "$backup_file" "Backup File"

base_folder="${BASE_FOLDER:-$(read -p "📂 Enter the base folder path: " tmp && echo "$tmp")}"
check_blank "$base_folder" "Base Folder"

restore_folder="${RESTORE_FOLDER:-$(read -p "📂 Enter the restore folder name: " tmp && echo "$tmp")}"
check_blank "$restore_folder" "Restore Folder"

# Combine base folder and restore folder
full_restore_path="${base_folder%/}/${restore_folder}"

echo "📂 Staging site will be created at: $full_restore_path"

# Step 1: Backup the Source Site
echo "📦 Creating a backup of the source site ($web_root/$folder_name)..."
backup-wp "$CONFIG_FILE"
if [[ $? -ne 0 ]]; then
    echo "❌ Backup failed. Aborting staging site setup."
    exit 1
fi
log_action "SUCCESS" "Source site backup completed."

# Step 2: Restore to the New Staging Site
echo "📤 Restoring backup to new staging site ($full_restore_path)..."
restore-wp "$CONFIG_FILE"
if [[ $? -ne 0 ]]; then
    echo "❌ Restore failed. Aborting staging site setup."
    exit 1
fi
log_action "SUCCESS" "Staging site restore completed."

echo "✅ Staging site setup is complete!"