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
echo "Working directory changed to /var/www/html"

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

if [[ -z "$foldername" ]]; then
  echo "Error: Folder name cannot be blank. Please provide a valid folder name."
  exit 1
fi

# Automatically derive dbname and URL
dbname="client_${foldername}"
url="$base_url/$foldername"
echo "Done gathering and setting values for settings"

# Create the directory and navigate into it
sudo -u www-data mkdir -p "$foldername" && sudo -u www-data chmod 775 "$foldername"
echo "Folder created"

cd "/var/www/html/$foldername" || exit

# Run commands as www-data
sudo -u www-data bash <<EOF
# Download WordPress core
wp core download
echo "Core downloaded."

# Create wp-config.php with database details
wp config create --dbname="$dbname" --dbuser="$dbuser" --dbpass="$dbpass"
echo "Config created"

# Create the database
wp db create
echo "DB created"

# Install WordPress
wp core install --url="$url" --title="$title" --admin_user="$adminuser" --admin_password="$adminpass" --admin_email="$adminemail"
echo "Core installed"
EOF

# Set proper permissions
sudo -u www-data find "/var/www/html/$foldername" -type d -exec chmod 755 {} \;
sudo -u www-data find "/var/www/html/$foldername" -type f -exec chmod 644 {} \;

echo "WordPress installation complete."