#!/bin/bash

echo "Usage: $0 <foldername> <title> [adminuser] [adminpass] [adminemail]"
echo "Default admin credentials will be used if none are provided."

echo "##### STEP 1 SETUP WORDPRESS STAGING SITE"

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
foldername=${1:-$(read -p "Enter folder/clientname name: " tmp && echo $tmp)}
title=${2:-$(echo "$foldername" | awk '{ print toupper(substr($0, 1, 1)) tolower(substr($0, 2)) }')}

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
    # Folder name is valid; proceed
    ;;
esac

# Automatically derive dbname and URL
dbname="client_${foldername}"
url="$base_url/$foldername"
echo "Done gathering and setting values for settings"

# Create the directory and navigate into it
echo "Create the directory and navigate into it"
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
echo "Set proper permissions"
sudo -u www-data find "/var/www/html/$foldername" -type d -exec chmod 755 {} \;
sudo -u www-data find "/var/www/html/$foldername" -type f -exec chmod 644 {} \;
echo "done"

echo "#### WordPress installation complete."



echo "##### STEP 2 CLONING PDRT3"
echo "performing pdrt3 content backup"
cd /var/www/html/pdrt3
sudo -u www-data tar --exclude='cache' -czvf "/var/www/html/$foldername/pdrt3-wp-content.tar.gz" wp-content
echo "done backing up wp-content of pdrt3"

cd /var/www/html/pdrt3
echo "exporting and importing db"
sudo -u www-data wp db export "/var/www/html/$foldername/wordpress.sql" --add-drop-table
echo "pdrt3 db exported"

new_prefix="pdrt1_"

cd "/var/www/html/$foldername"
wp db import "/var/www/html/$foldername/wordpress.sql"
echo "pdrt3 db imported"


echo "executing search-replace"
wp search-replace 'https://staging.appetiser.com.au/pdrt3' "$url" --skip-columns=guid --all-tables
echo "done."

echo "uncompressing wp-content"
cd "/var/www/html/$foldername/"
sudo -u www-data tar -xzvf "/var/www/html/$foldername/pdrt3-wp-content.tar.gz"
echo "done."

echo "#### pdrt3 cloned."

echo "Resetting proper permissions..."
sudo -u www-data find "/var/www/html/$foldername" -type d -exec chmod 755 {} \;
sudo -u www-data find "/var/www/html/$foldername" -type f -exec chmod 644 {} \;
echo "done"

cd "/var/www/html/$foldername/"
echo "Updating settings"
wp option update home "$url"
wp option update siteurl "$url"

# Update wp-config.php with the new table prefix
echo "Updating table prefix in wp-config.php..."
sudo -u www-data wp config set table_prefix "$new_prefix" --type=variable
echo "Table prefix updated."

sudo -u www-data wp config set FS_METHOD 'direct' --type=constant
sudo -u www-data wp config set ALLOW_UNFILTERED_UPLOADS true --type=constant --raw

echo "Updating site title."
wp option update blogname "$foldername"
echo "Site title updated."

echo "#### settings done"

wp cache flush
