#!/usr/bin/env bash

# Variables from Vagrantfile
APP=$1
DOCROOT=$2

echo "Enabling nointeractive mode for Debian ..."
export DEBIAN_FRONTEND=noninteractive

echo "Updating and upgrading operation system ..."
apt-get update && apt-get upgrade

echo "Installing all locales ..."
apt-get install locales-all

echo "Installing essentials ..."
apt-get install -y curl git mc rsync

echo "Installing graphic libs ..."
apt-get install -y ghostscript graphicsmagick-imagemagick-compat

echo "Installing PHP with essential extensions ..."
apt-get install -y php5-cli \
php5-curl \
php5-fpm \
php5-gd \
php5-gmp \
php5-imagick \
php5-intl \
php5-ldap \
php5-mcrypt \
php5-mysql \
php5-pspell \
php5-recode \
php5-sqlite \
php5-tidy \
php5-xsl \
php-pear

echo "Installing additional PHP extensions ..."
apt-get install -y php-apc

echo "Creating pool configuration"
cat > /etc/php5/fpm/pool.d/vagrant.conf <<EOF
[vagrant]
listen = /var/run/php5-fpm-vagrant.sock
listen.backlog = 4096
user = vagrant
group = vagrant
listen.owner = vagrant
listen.group = vagrant
listen.allowed_clients = 127.0.0.1
listen.mode = 0660
pm = dynamic
pm.max_children = 10
pm.start_servers = 3
pm.min_spare_servers = 3
pm.max_spare_servers = 5
pm.max_requests = 40
env[HOSTNAME] = $HOSTNAME
env[PATH] = /usr/local/bin:/usr/bin:/bin
env[TMP] = /tmp
env[TMPDIR] = /tmp
env[TEMP] = /tmp
php_admin_value[open_basedir] = /var/www/:/tmp/
php_admin_value[date.timezone] = Europe/Berlin

# Performance Tweaks
php_admin_value[realpath_cache_size] = 4096k
php_admin_value[realpath_cache_ttl] = 7200
EOF
service php5-fpm restart

echo "Installing Composer ..."
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

echo "Installing nginx webserver ..."
apt-get install -y nginx nginx-extras

echo "Configuring nginx webserver ..."
if [ -f /etc/nginx/sites-enabled/default ]; then
	echo "Removing default nginx server block ..."
	rm /etc/nginx/sites-enabled/default
fi

echo "Disabling sendfile because of a bug in VirtualBox ..."
echo "More Details: http://docs.vagrantup.com/v2/synced-folders/virtualbox.html"
sed -i 's/sendfile on/sendfile off/g' /etc/nginx/nginx.conf

echo "Configuring nginx server block for PHP project ..."
cat > /etc/nginx/sites-available/vagrant <<EOF
server {
	listen 80;
	listen [::]:80;

	root /var/www/$DOCROOT;
	server_name _;

	index index.html index.php;

	location / {
		try_files \$uri \$uri/ /index.html;
	}

	location ~ \.php$ {
		try_files \$uri =404;
		fastcgi_pass unix:/var/run/php5-fpm-vagrant.sock;
		fastcgi_index index.php;
		fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
		include fastcgi_params;
	}
}
EOF

echo "Allowing www-data to access php socket file of vagrant user ..."
adduser www-data vagrant

if ! [ -L /etc/nginx/sites-enabled/vagrant ]; then
	echo "Enabling new nginx server block ..."
	ln -s /etc/nginx/sites-available/vagrant /etc/nginx/sites-enabled/
fi

echo "Linking shared folder with nginx document root..."
if ! [ -L /var/www ]; then
  rm -rf /var/www
  ln -fs /vagrant/ /var/www
fi
service nginx reload

echo "Adding command to change folder on 'vagrant ssh'..."
echo "cd /var/www/" >> /home/vagrant/.bashrc

echo "Installing MariaDB ..."
echo "Preparing unattended installation of MariaDB ..."
MYSQL_ROOT_PASS="vagrant"
echo "Setting MySQL root password ('$MYSQL_ROOT_PASS') ..."
debconf-set-selections <<< "mariadb-server-5.5 mysql-server/root_password password $MYSQL_ROOT_PASS"
debconf-set-selections <<< "mariadb-server-5.5 mysql-server/root_password_again password $MYSQL_ROOT_PASS"

echo "Installing MySQL server ..."
apt-get install -y --allow-unauthenticated mariadb-server mariadb-client

echo "Setting credential file for auto login root user ..."
cat > /root/.my.cnf <<EOF
[mysql]
user=root
password=$MYSQL_ROOT_PASS
[mysqldump]
user=root
password=$MYSQL_ROOT_PASS
EOF
chmod 700 /root/.my.cnf

echo "Creating MySQL user for project ..."
MYSQL_VAGRANT_DB="vagrant"
MYSQL_VAGRANT_USER="vagrant"
MYSQL_VAGRANT_PASS="vagrant"
echo "Creating MySQL user '$MYSQL_VAGRANT_USER' with password '$MYSQL_VAGRANT_PASS' (Host = localhost) for project ..."
#mysql -e "CREATE USER '$MYSQL_VAGRANT_USER'@'localhost' IDENTIFIED BY '$MYSQL_VAGRANT_PASS'"
mysql -e "GRANT ALL ON $MYSQL_VAGRANT_DB.* TO '$MYSQL_VAGRANT_USER'@'localhost' identified by '$MYSQL_VAGRANT_PASS'"
echo "Creating MySQL database for project ..."
mysql -e "CREATE DATABASE IF NOT EXISTS $MYSQL_VAGRANT_DB DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;"
echo "Setting priviliges for database usage ..."
#mysql -e "GRANT ALL PRIVILEGES ON *.* TO '$MYSQL_VAGRANT_USER'@'localhost' IDENTIFIED BY '$MYSQL_VAGRANT_PASS' WITH GRANT OPTION;" mysql

echo "Setting credential file for auto login root user ..."
cat > /home/vagrant/.my.cnf <<EOF
[mysql]
user=$MYSQL_VAGRANT_USER
password=$MYSQL_VAGRANT_PASS
[mysqldump]
user=$MYSQL_VAGRANT_USER
password=$MYSQL_VAGRANT_PASS
EOF

APP=$1
echo "Selected App: $APP"