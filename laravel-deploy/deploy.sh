#!/bin/bash

# Script info
SCRIPT_TITLE="Laravel Deployment Script"
SCRIPT_VERSION="1.0"
SCRIPT_AUTHOR="Santanu Biswas"
SCRIPT_AUTHOR_WEBSITE="https://www.meetsantanu.in/"
SCRIPT_GITHUB="https://github.com/mrsanta79/shell-scripts/main/laravel-deploy"
SCRIPT_DESCRIPTION="This script will install and configure a LAMP stack for your Laravel application on your freshly installed Ubuntu server."

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

# Show welcome message
echo -e "\n${REDORANGE}This script will install and configure a LAMP stack for Laravel on your Ubuntu server."
echo -e "${YELLOW}It is recommended to run this script on a fresh Ubuntu server installation."
echo -e "\n${YELLOW}Before running this script, make sure you have superuser (sudo) privileges."
echo -e "\n${GREEN}This script will install the following:"
echo -e "${GREEN} - Apache web server"
echo -e "${GREEN} - MySQL database server (MariaDB)"
echo -e "${GREEN} - PHP"
echo -e "${GREEN} - Composer"
echo -e "${GREEN} - Laravel application from git repository"
echo -e "${GREEN} - NodeJS"
echo -e "${GREEN} - NPM"
echo -e "${GREEN} - Yarn\n\n"

# Let user select php version or set default
read -p "Choose your preferred PHP version (example: 7.4, 8.0, 8.1, 8.2; default: 8.2): " php_version
php_version=${php_version:-8.2}

# Let user select node version or set default
read -p "Choose your preferred NodeJS version (example: 14, 16, 18; default: 18): " node_version
node_version=${node_version:-18}

# Ask user if they want to install database or not
read -p "Do you want to install MariaDB database? (y/n; default: n): " install_database
install_database=${install_database:-n}

# Ask for git url for laravel project
read -p "Provide the git url of the laravel application: " git_url

# Ask for laravel project directory or set default
read -p "Enter the website directory name where the application will be deployed under /var/www/<dir> (default: application): " site_dir_name
site_dir_name=${site_dir_name:-application}

# Ask for website domain name
read -p "Enter website domain name (example: example.com): " site_domain
site_domain=${site_domain:-example.com}

# Start installation
echo -e "\n${PURPLE}Starting installation...\n"

# Update Ubuntu's package index
sudo apt update

# Install Apache web server
sudo apt install -y apache2
sudo systemctl enable apache2 --now

# Install MySQL database server if user wants to
if [ "$install_database" = "y" ]; then
    sudo apt install -y mariadb-server
    sudo systemctl enable mariadb --now

    # Secure the MySQL installation
    sudo mysql_secure_installation

    # Guide step by step to create a new database for Laravel
    echo -e "\n${GREEN}Please follow the steps below to create a new database for Laravel application when the MySQL prompt appears:"

    echo -e "\n${CYAN}1. CREATE DATABASE \`[database-name]\`;"
    echo -e "${CYAN}2. CREATE USER '[database-user]'@'localhost' IDENTIFIED BY '[database-password]';"
    echo -e "${CYAN}3. GRANT ALL PRIVILEGES ON \`[database-name]\`.* TO '[database-user]'@'localhost' IDENTIFIED BY '[database-password]';"
    echo -e "${CYAN}4. FLUSH PRIVILEGES;"
    echo -e "${CYAN}5. EXIT;"

    echo -e "\n${REDORANGE}NOTE: Replace [database-name], [database-user] and [database-password] with your own values."

    # Start MySQL prompt
    echo -e "\n${GREEN}Starting MySQL prompt..."
    sudo mysql -u root -p

    # Continue installation
    echo -e "\n${PURPLE}Continuing installation...\n"
fi

# Install PHP version and necessary extensions
sudo apt install -y software-properties-common
sudo add-apt-repository -y ppa:ondrej/php
sudo apt update
sudo apt install -y curl wget git unzip python3 php$php_version
sudo update-alternatives --set php /usr/bin/php$php_version
sudo apt install -y php-{cli,mysql,common,mbstring,xml,curl,mysql,zip,gd,bcmath,imagick,ldap,redis,soap,tidy,xmlrpc,xdebug,dev,bz2,intl,memcached,msgpack,igbinary,ssh2,ldap,redis,smbclient,sqlite3,swoole} \
    php$php_version-{cli,mysql,common,mbstring,xml,curl,mysql,zip,gd,bcmath,imagick,ldap,redis,soap,tidy,xmlrpc,xdebug,dev,bz2,intl,memcached,msgpack,igbinary,ssh2,ldap,redis,smbclient,sqlite3,swoole}
sudo apt install -y php7.4-json php-json libapache2-mod-php$php_version
sudo snap install --classic certbot

# Configure Apache to use PHP
sudo a2enmod php$php_version

# Install Composer
sudo curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer

# Install NodeJS from NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash

# Load NVM
. ~/.nvm/nvm.sh

# Install NodeJS from selected version
nvm install $node_version

# Add source to bashrc, zshrc or fish config if available and not already added
if [ -f ~/.bashrc ]; then
    if ! grep -q "source ~/.nvm/nvm.sh" ~/.bashrc; then
        echo "source ~/.nvm/nvm.sh" >> ~/.bashrc
    fi
fi

if [ -f ~/.zshrc ]; then
    if ! grep -q "source ~/.nvm/nvm.sh" ~/.zshrc; then
        echo "source ~/.nvm/nvm.sh" >> ~/.zshrc
    fi
fi

if [ -f ~/.config/fish/config.fish ]; then
    if ! grep -q "source ~/.nvm/nvm.sh" ~/.config/fish/config.fish; then
        echo "source ~/.nvm/nvm.sh" >> ~/.config/fish/config.fish
    fi
fi

# Install NPM
npm install -g npm yarn

# Show logout and login warning for nvm
echo -e "\n${YELLOW}Please logout and login again to use nvm manually.\n"

# Configure a virtual host for Laravel
sudo mkdir -p /var/www/$site_dir_name
sudo chown -R $USER:$USER /var/www/$site_dir_name
sudo chmod -R 755 /var/www/$site_dir_name

# Clone laravel project
git clone $git_url /var/www/$site_dir_name

# Set laravel directory and file permissions
cd /var/www/$site_dir_name
sudo chown -R $USER:www-data /var/www/$site_dir_name
sudo usermod -aG www-data $USER
sudo find /var/www/$site_dir_name -type f -exec chmod 644 {} \;
sudo find /var/www/$site_dir_name -type d -exec chmod 755 {} \;
sudo chgrp -R www-data storage bootstrap/cache
sudo chmod -R ug+rwx storage bootstrap/cache
mkdir -p storage/framework/{sessions,views,cache}
chmod -R 777 storage bootstrap/cache

# Set php memory limit
sudo sed -i 's/memory_limit = .*/memory_limit = 512M/' /etc/php/$php_version/apache2/php.ini

# Set php upload limit
sudo sed -i 's/upload_max_filesize = .*/upload_max_filesize = 512M/' /etc/php/$php_version/apache2/php.ini

# Install laravel dependencies
composer install

# Installl npm dependencies if package.json exists
if [ -f "package.json" ]; then
    sudo npm install
fi

# Create apache config file
sudo truncate -s 0 /etc/apache2/sites-available/$site_domain.conf
sudo tee -a /etc/apache2/sites-available/$site_domain.conf <<EOF
<VirtualHost *:80>
    ServerName $site_domain
    ServerAlias www.$site_domain
    DocumentRoot /var/www/$site_dir_name/public

    <Directory /var/www/$site_dir_name>
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/laravel-error.log
    CustomLog \${APACHE_LOG_DIR}/laravel-access.log combined
</VirtualHost>
EOF

sudo a2dissite 000-default.conf
sudo a2ensite $site_domain.conf
sudo a2enmod rewrite

# Restart Apache server to apply changes
sudo systemctl restart apache2

# Link laravel storage to public directory
php artisan storage:link

# Generate laravel application key
cp .env.example .env
php artisan key:generate

# Finish message
echo -e "\n\n${BLUE}Laravel application is now deployed and configured.\n"
echo -e "\n${BLUE}To finalize the installation, please follow the steps below:\n"
echo -e "${BLUE}1. Edit .env file and make necessry changes."
echo -e "${BLUE}2. Run 'php artisan migrate:fresh --seed' to migrate database."

# End of script