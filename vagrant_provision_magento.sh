#!/usr/bin/env bash

APP=$1
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

	location ~ .php$ {
		fastcgi_pass unix:/tmp/php5-fpm.sock;
		fastcgi_index index.php;
		include fastcgi_params;
	}

	location ~ /\.ht {
		deny all;
	}
}

EOF
service nginx reload