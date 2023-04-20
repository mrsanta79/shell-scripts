#!/bin/sh

# Script info
SCRIPT_TITLE="Laravel Virtual Host Local"
SCRIPT_VERSION="1.0"
SCRIPT_AUTHOR="Santanu Biswas"
SCRIPT_AUTHOR_WEBSITE="https://www.meetsantanu.in/"
SCRIPT_GITHUB="https://github.com/mrsanta79/shell-scripts/tree/main/laravel-vhost-local"
SCRIPT_DESCRIPTION="This script deletes a local vhost that is already running for your Laravel application using Apache2 web server."

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

# Get domain name
echo -n "\n${LGRAY}Enter the domain name of your Laravel application (example: myapp): ${NC}" && read domain_name

# Check if domain name is present in apache2 vhost
if grep -q "$domain_name" /etc/apache2/sites-available/*; then

    # Confirm
    echo "\n${RED}Are you sure you want to delete the vhost for $domain_name.test?${NC}"
    echo -n "${LGRAY}Type 'yes' to confirm: ${NC}" && read confirm
    if [ "$confirm" != "yes" ] && [ "$confirm" != "y" ]; then
        echo "\n${RED}Laravel vhost not deleted!${NC}"
        exit 1
    fi

    # Delete the vhost
    sudo a2dissite $domain_name
    sudo rm /etc/apache2/sites-available/$domain_name.conf
    sudo systemctl restart apache2

    # Delete domain name from hosts file
    sudo sed -i "/$domain_name.test/d" /etc/hosts
    sudo sed -i "/www.$domain_name.test/d" /etc/hosts
    sudo sed -i "/The following domain was added by laravel-vhost-local script/d" /etc/hosts

    echo "\n${GREEN}Laravel vhost deleted successfully!${NC}\n"
else
    echo "\n${RED}Laravel vhost not found!${NC}\n"
fi
