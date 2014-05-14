#!/usr/bin/env bash

# From Creating a Vagrant Box
echo "export PS1='devl4:\w\$ '" >> .bashrc
cat << EOF | sudo tee -a /etc/motd.tail
***************************************

Welcome to precise32-vanilla Vagrant Box

For PHP development

***************************************
EOF


sudo apt-get update
sudo apt-get -f install

# Install Vim
apt-get install -y vim

sudo apt-get install -y python-software-properties build-essential

# Install Apache
sudo apt-get install -y apache2 libapache2-mod-php5
sudo a2enmod rewrite

# Install OpenSSL
apt-get -y install openssl

# Enable SSL
a2enmod ssl

# Add www-data to vagrant group
usermod -a -G vagrant www-data

# Add ServerName to httpd.conf
echo "ServerName localhost" > /etc/apache2/httpd.conf

# Setup hosts file
VHOST=$(cat <<EOF
<VirtualHost *:80>
  DocumentRoot "/var/www/public"
  ServerName localhost
  <Directory "/var/www/public">
    AllowOverride All
  </Directory>
</VirtualHost>
EOF
)
echo "${VHOST}" > /etc/apache2/sites-enabled/000-defa


### From Installing MySQL
# Ignore the post install questions
export DEBIAN_FRONTEND=noninteractive
echo 'mysql-server mysql-server/root_password password root' | sudo debconf-set-selections
echo 'mysql-server mysql-server/root_password_again password root' | sudo debconf-set-selections

sudo apt-get install -q -y mysql-server-5.5

cat << EOF | sudo tee -a /etc/mysql/conf.d/default_engine.cnf
[mysqld]
default-storage-engine = Innodb
EOF

### Enable remote access mysql
mysql -uroot -proot -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root' WITH GRANT OPTION; FLUSH PRIVILEGES;"
sudo sed -i "s/^bind-address/#bind-address/" /etc/mysql/my.cnf
sudo service mysql restart

### Install PHP
sudo apt-get install -y git-core curl wget php5 php5-mysql \
 php5-cli php5-curl php5-mcrypt php5-gd php5-xdebug

### xdebug
cat << EOF | sudo tee -a /etc/php5/conf.d/xdebug.ini
xdebug.scream=1
xdebug.cli_color=1
xdebug.show_local_vars=1
EOF

###show errros and allowOverride apache
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php5/apache2/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php5/apache2/php.ini
sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf

 ### From Installing Composer
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer


### Restart Apache
sudo service apache2 restart


# Install NFS client
sudo apt-get -y install nfs-common portmap

##set permissions to storage path
sudo chmod -R 777 /var/www/app/storage

##create database for dev
mysql -uroot -proot -e "CREATE DATABASE IF NOT EXISTS mydb_name; USE mydb_name; GRANT SELECT, INSERT, DELETE, UPDATE, CREATE, ALTER, DROP ON aduauybt_sata2.*
TO 'app_user'@'localhost' IDENTIFIED BY 'secret_password';"


echo "You've been provisioned"
