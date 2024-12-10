# WordPress Staging Site Setup Script

This script automates the process of setting up a WordPress staging site by performing the following tasks:
1. Downloads and installs WordPress in a specified directory.
2. Configures database settings and WordPress options.
3. Clones content and database from an existing WordPress site (`pdrt3`).
4. Updates URLs, table prefixes, and site-specific settings.

## Requirements

1. **System Requirements**:
   - Bash shell
   - `sudo` privileges for the user executing the script
   - Access to the `/var/www/html` directory
   - WP-CLI installed and configured

2. **Dependencies**:
   - The `pdrt3` WordPress installation in `/var/www/html/pdrt3`

## Usage

### Command Syntax
```bash
./install-wp.sh <foldername> <title> [adminuser] [adminpass] [adminemail]