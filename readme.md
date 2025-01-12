# WordPress Staging Site Installation

## Introduction
This bash script automates the process of setting up WordPress staging sites for clients. It performs a complete WordPress installation and clones the PDRT3 template site, making it ready for client-specific customization. The script handles everything from creating directories and databases to configuring WordPress settings and managing permissions.

## Prerequisites

### WP-CLI Installation
The script requires WP-CLI to be installed on your system. WP-CLI is a command-line interface for WordPress that enables you to manage WordPress installations without using a web browser.

To install WP-CLI:
```bash
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp
```

Verify the installation:
```bash
wp --info
```

## Script Workflow

### Step 1: WordPress Installation
1. Checks for WP-CLI installation
2. Navigates to web server root directory (`/var/www/html`)
3. Sets up database credentials and base URL
4. Creates necessary directories with proper permissions
5. Downloads WordPress core files
6. Creates wp-config.php with database configuration
7. Creates the database
8. Installs WordPress with specified admin credentials
9. Sets proper file permissions

### Step 2: PDRT3 Template Cloning
1. Creates backup of PDRT3 wp-content
2. Exports PDRT3 database
3. Imports database to new installation
4. Performs search-replace for URLs
5. Extracts wp-content backup
6. Updates WordPress settings:
   - Home URL
   - Site URL
   - Table prefix
   - File system method
   - Upload filters
   - Site title
7. Cleans up temporary files
8. Flushes cache

## Usage

### Running the Script
The script is executed using the `staging-install` command:

```bash
staging-install <foldername>
```

Example:
```bash
staging-install client123
```

### Parameters
- `foldername`: The name of the client folder (required)
- Default admin credentials will be used if none are provided:
  - Username: appetiser
  - Password: zj^!uV8thz&Xi6zV20FI4i8Q
  - Email: norbert.feria@appetiser.com.au

### Generated URLs and Paths
- Staging URL: `https://staging.appetiser.com.au/<foldername>`
- Installation Directory: `/var/www/html/<foldername>`
- Database Name: `client_<foldername>`

## Notes
- The script must be run with appropriate permissions to access `/var/www/html`
- All files and directories are set to standard WordPress permissions (755 for directories, 644 for files)
- The script includes error handling for common issues like missing directories or invalid folder names
- Database credentials are hardcoded in the script for staging environment use