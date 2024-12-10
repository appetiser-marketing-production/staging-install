#!/bin/bash

echo "Usage: $0 <foldername> <title> [adminuser] [adminpass] [adminemail]"
echo "Default admin credentials will be used if none are provided."

# Check if wp-cli is installed
if ! which wp > /dev/null; then
  echo "wp-cli could not be found. Please install wp-cli before running this script."
  exit 1
fi

# Navigate to the web server's root directory
cd /var/www/html || { echo "Failed to navigate to /var/www/html. Ensure the directory exists."; exit 1; }
echo "working directory changed to /var/www/html"

# Database credentials
dbuser="myuser"
dbpass="mypassword"

base_url="https://staging.appetiser.com.au"

# Get input or arguments
foldername=${1:-$(read -p "Enter folder name: " tmp && echo $tmp)}
title=${2:-$(read -p "Enter site title: " tmp && echo $tmp)}

# Default admin credentials
adminuser=${3:-"appetiser"}
adminpass=${4:-"zj^!uV8thz&Xi6zV20FI4i8Q"}
adminemail=${5:-"norbert.feria@appetiser.com.au"}

case "$foldername" in
  "")
    echo "Error: Folder name cannot be blank. Please provide a valid folder name."
    exit 1
    ;;
  *)
    # Proceed as normal
    ;;
esac

# Automatically derive dbname and URL
dbname="client_${foldername}"
url="$base_url/$foldername"

echo "Done gathering and setting values for settings"

# Create the directory and navigate into it
mkdir -p "$foldername" && chmod 775 "$foldername"
echo "folder created"

cd "/var/www/html/$foldername"  || exit

# Download WordPress core
wp core download
echo "core downloaded."

# Create wp-config.php with database details
wp config create --dbname="$dbname" --dbuser="$dbuser" --dbpass="$dbpass"
echo "config created"

# Create the database
wp db create
echo "db created"

# Install WordPress
wp core install --url="$url" --title="$title" --admin_user="$adminuser" --admin_password="$adminpass" --admin_email="$adminemail"
echo "core installed"

# Set ownership
echo "Setting ownership to www-data..."
chown -R www-data:www-data "/var/www/html/$foldername"

# Set proper permissions
echo "Setting proper file and directory permissions..."
find "/var/www/html/$foldername" -type d -exec chmod 755 {} \;
find "/var/www/html/$foldername" -type f -exec chmod 644 {} \;

echo "WordPress installation complete."

# Ensure the final working directory is /var/www/html
cd "/var/www/html/$foldername" 