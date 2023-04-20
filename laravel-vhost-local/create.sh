#!/bin/sh

# Script info
SCRIPT_TITLE="Laravel Virtual Host Local"
SCRIPT_VERSION="1.0"
SCRIPT_AUTHOR="Santanu Biswas"
SCRIPT_AUTHOR_WEBSITE="https://www.meetsantanu.in/"
SCRIPT_GITHUB="https://github.com/mrsanta79/shell-scripts/tree/main/laravel-vhost-local"
SCRIPT_DESCRIPTION="This script creates a local vhost for your Laravel application using Apache2 web server."

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LGRAY='\033[0;37m'
REDORANGE='\033[0;38m'
NC='\033[0m' # No color

# Make sure the script is run as root
if [ "$(id -u)" != "0" ]; then
    echo "\n${RED}This script must be run as root or superuse (sudo) privilege!${NC}\n" 1>&2
    exit 1
fi

# Set the base path for your Laravel apps
echo -n "\n${LGRAY}Enter the absolute base path for your Laravel application: ${NC}" && read app_path

# Get domain name
echo -n "\n${LGRAY}Enter the domain name for your Laravel application (example: myapp): ${NC}" && read domain_name

# Return and exit if domain name or base path is empty or base path does not exist
if [ -z "$domain_name" ] || [ -z "$app_path" ] || [ ! -d "$app_path" ]; then
    echo "\n${RED}Invalid domain name or base path!${NC}"
    exit 1
fi

echo "\n${PURPLE}Creating vhost for $domain_name.test...\n${NC}"

# Create the Apache vhost configuration file
sudo truncate -s 0 /etc/apache2/sites-available/$domain_name.conf
sudo cat > /etc/apache2/sites-available/$domain_name.conf <<EOF
<VirtualHost *:80>
    ServerName $domain_name.test
    ServerAlias www.$domain_name.test
    DocumentRoot $app_path/public

    <Directory $app_path>
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog /var/log/apache2/${domain_name}_error.log
    CustomLog /var/log/apache2/${domain_name}_access.log combined
</VirtualHost>
EOF

# Enable the vhost
sudo a2ensite $domain_name

# Check if domain name is already in hosts file
if grep -q "$domain_name.test" /etc/hosts; then
    echo "\n${PURPLE}$domain_name.test already exists in /etc/hosts${NC}"
else
    # Add domain name to hosts file
    echo "\nThe following domain was added by laravel-vhost-local script" >> /etc/hosts
    echo "127.0.0.1   $domain_name.test www.$domain_name.test" >> /etc/hosts
    echo "\n${PURPLE}Added $domain_name.test to /etc/hosts${NC}\n"
fi

sudo systemctl restart systemd-resolved

# Get the current installed PHP version
CURRENT_PHP_VERSION=$(php -v | head -n 1 | cut -d " " -f 2 | cut -d "." -f 1-2)

# Restart Apache to apply the changes
sudo a2enmod rewrite && sudo a2enmod php$CURRENT_PHP_VERSION
sudo systemctl restart apache2

echo "\n${GREEN}Laravel vhost created successfully!${NC}"
echo "${GREEN}You can now access your Laravel application at http://$DOMAIN_NAME.test${NC}\n"
