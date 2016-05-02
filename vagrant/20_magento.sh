#!/usr/bin/env bash

APP=$1
DOCROOT=$2
if [ "$APP" != "magento" ]
then
	echo "No Magento configuration selected."
	exit 0
fi

echo "Configuring nginx server block for Magento ..."
cat > /etc/nginx/sites-available/vagrant <<EOF
server {
	listen 80;
	listen [::]:80;

	root /var/www/$DOCROOT;
	server_name _;

	index index.php;
	try_files \$uri \$uri/ index.php\$is_args\$args;

	#Magento
    location / {
    	## Allow a static html file to be shown first
        index index.html index.php;

        ## If missing pass the URI to Magento's front handler
        try_files \$uri \$uri/ @handler;

        ## Assume all files are cachable
        expires 30d;
    }

    ## These locations would be hidden by .htaccess normally
    location /app/                { deny all; }
    location /includes/           { deny all; }
    location /lib/                { deny all; }
    location /media/downloadable/ { deny all; }
    location /pkginfo/            { deny all; }
    location /report/config.xml   { deny all; }
    location /var/                { deny all; }

    ## Disable .htaccess and other hidden files
    location ~ /\. {
        deny all;
        access_log off;
        log_not_found off;
    }

	## Magento uses a common front handler
    location @handler {
        rewrite / /index.php;
    }

	## Forward paths like /js/index.php/x.js to relevant handler
    location ~ \.php/ {
        rewrite ^(.*\.php)/ \$1 last;
    }

    location ~ \.php\$ { ## Execute PHP scripts
    	## Catch 404s that try_files miss
        if (!-e \$request_filename) { rewrite / /index.php last; }

        expires off;
        fastcgi_pass unix:/var/run/php5-fpm-vagrant.sock;
		fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param MAGE_RUN_CODE default;
        fastcgi_param MAGE_RUN_TYPE store;
    }
}

EOF
service nginx reload

echo "Installing modman ..."
bash < <(curl -s -L https://raw.github.com/colinmollenhour/modman/master/modman-installer)
mv ~/bin/modman /usr/local/bin/

echo "Installing magerun ..."
wget https://files.magerun.net/n98-magerun.phar
chmod +x n98-magerun.phar
mv n98-magerun.phar /usr/local/bin/n98-magerun.phar
if ! [ -L /usr/local/bin/magerun ]; then
    ln -s /usr/local/bin/n98-magerun.phar /usr/local/bin/magerun
fi