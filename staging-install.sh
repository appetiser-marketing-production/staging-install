#!/bin/bash

echo "Usage: $0 <foldername> <dbname> <url> <title> <adminuser> <adminpass> <adminemail>"
echo "Or you can enter the details."

# Check if wp-cli is installed
if ! which wp > /dev/null; then
  echo "wp-cli could not be found. Please install wp-cli before running this script."
  exit 1
fi

# Navigate to the web server's root directory
cd /var/www/html || { echo "Failed to navigate to /var/www/html. Ensure the directory exists."; exit 1; }

# Database credentials
dbuser="myuser"
dbpass="mypassword"

base_url="https://staging.appetiser.com.au"

# Check if a variable is passed as an argument; if not, prompt for input.
foldername=${1:-$(read -p "Enter folder name: " tmp && echo $tmp)}
dbname="client_${foldername}"
url="$base_url/$foldername"
title=${4:-$(read -p "Enter site title: " tmp && echo $tmp)}
adminuser=${5:-$(read -p "Enter admin username: " tmp && echo $tmp)}
adminpass=${6:-$(read -p "Enter admin password: " tmp && echo $tmp && echo "")}
adminemail=${7:-$(read -p "Enter admin email: " tmp && echo $tmp)}

# Create the directory and navigate into it
sudo mkdir -p "$foldername"
sudo chmod -R 775 "/var/www/html/$foldername"
cd "$foldername" || exit

# Download WordPress core
wp core download

# Create wp-config.php with database details
wp config create --dbname="$dbname" --dbuser="$dbuser" --dbpass="$dbpass"

# Create the database
wp db create

# Install WordPress
wp core install --url="$url" --title="$title" --admin_user="$adminuser" --admin_password="$adminpass" --admin_email="$adminemail"

# Set ownership
echo "Setting ownership to www-data..."
sudo chown -R www-data:www-data .

# Set proper permissions
echo "Setting proper file and directory permissions..."
sudo find . -type d -exec chmod 775 {} \;
sudo find . -type f -exec chmod 644 {} \;

echo "WordPress installation complete."