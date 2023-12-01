#!/bin/sh

# Script info
SCRIPT_TITLE="PHP Version Switch Script"
SCRIPT_VERSION="1.0"
SCRIPT_AUTHOR="Santanu Biswas"
SCRIPT_AUTHOR_WEBSITE="https://www.meetsantanu.in/"
SCRIPT_GITHUB="https://github.com/mrsanta79/shell-scripts/tree/main/php-version-switch"
SCRIPT_DESCRIPTION="This script allows you to switch between different PHP versions by completely removing the old version and installing the new one."

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

# Exit if OS is not Ubuntu or Debian
if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [ "$ID" != "ubuntu" ] && [ "$ID_LIKE" != "ubuntu" ] && [ "$ID" != "debian" ] && [ "$ID_LIKE" != "debian" ] && [ "$ID_LIKE" != "ubuntu debian" ]; then
        echo "\n${RED}This script is for Ubuntu and Debian based operating systems only!${NC}\n"
        exit 1
    fi
fi

# Let user select php version or set default
echo -n "\n${LGRAY}Choose the PHP version you want to install (example: 7.4, 8.0, 8.1, 8.2; default: 8.2): " && read php_version
php_version=${php_version:-8.2}

# Check if php is already installed
if [ -x "$(command -v php)" ]; then
    php_version_installed=$(php -v | head -n 1 | cut -d " " -f 2 | cut -d "." -f 1-2)

    # Check if user wants to install the same version
    if [ "$php_version" = "$php_version_installed" ]; then
        echo "\n${LGRAY}PHP ${php_version_installed} is already installed!"
        echo "${RED}Installation finished! No changes made.${NC}"
        exit 1
    fi

    # Show warning
    echo "\n${PURPLE}You currently have PHP ${php_version_installed} installed!"

    # Ask user to confirm
    echo -n "\n${LGRAY}In order to continue, all the PHP ${php_version_installed} packages needs to be removed first. Type 'yes' to continue: " && read uninstall_confirmaion
    if [ "$uninstall_confirmaion" != "yes" ] && [ "$uninstall_confirmaion" != "y" ]; then
        echo "${RED}Installation aborted!${NC}"
        exit 1
    fi

    # Remove PHP
    echo "\n${PURPLE}Removing PHP ${php_version_installed}...\n${NC}"
    sudo apt purge "php${php_version_installed}-*" -y && sudo apt autoremove -y && sudo apt autoclean -y
fi

echo "\n${PURPLE}Starting installation of PHP ${php_version}...\n${NC}";

# Add necessary packages
sudo apt install -y ca-certificates apt-transport-https software-properties-common

# Check if Ubuntu or Debian
add_ondrej_for_debian() {
    curl -sSL https://packages.sury.org/php/README.txt | sudo bash -x
}

# Add ondrej/php repository if not already added
add_ondrej_for_ubuntu() {
    if [ ! -f /etc/apt/sources.list.d/ondrej-php.list ]; then
        sudo add-apt-repository ppa:ondrej/php -y
    fi
}

# Check if Ubuntu or Debian
if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [ "$ID" = "ubuntu" ] || [ "$ID_LIKE" = "ubuntu" ] || [ "$ID_LIKE" = "ubuntu debian" ]; then
        add_ondrej_for_ubuntu
    elif [ "$ID" = "debian" ] || [ "$ID_LIKE" = "debian" ]; then
        add_ondrej_for_debian
    fi
fi

# Update apt
sudo apt update

# Install PHP version and necessary extensions
sudo apt install -y curl wget zip unzip git
sudo apt install -y php$php_version php$php_version-common php$php_version-cli
sudo update-alternatives --set php /usr/bin/php$php_version
sudo apt install -y php$php_version-filter php$php_version-pcre php$php_version-pear php$php_version-session
sudo apt install -y php$php_version-bcmath php$php_version-ctype php$php_version-dom php$php_version-fileinfo php$php_version-json php$php_version-mbstring php$php_version-pdo php$php_version-tokenizer php$php_version-zip php$php_version-gd php$php_version-imagick php$php_version-mysql
sudo apt install -y php7.4-json libapache2-mod-php$php_version php$php_version-fpm
sudo apt install -y php$php_version-curl php$php_version-xml

# Set php memory limit
sudo sed -i 's/memory_limit = .*/memory_limit = 512M/' /etc/php/$php_version/apache2/php.ini

# Set php upload limit
sudo sed -i 's/upload_max_filesize = .*/upload_max_filesize = 256M/' /etc/php/$php_version/apache2/php.ini
sudo sed -i 's/post_max_size = .*/post_max_size = 256M/' /etc/php/$php_version/apache2/php.ini

echo "\n${PURPLE}Installation of PHP ${php_version} finished!\n"