#!/usr/bin/env bash

APP=$1
DOCROOT=$2

if [ "$APP" != "wordpress" ]
then
	echo "No WordPress configuration selected."
	exit 0
fi

echo "Configuring nginx server block for WordPress ..."

cat > /etc/nginx/sites-available/vagrant <<EOF
server {
	listen 80;
	listen [::]:80;

	root /var/www/$DOCROOT;
	server_name _;

	index index.php;

	location / {
		try_files \$uri \$uri/ /index.php?\$args;
	}

	# Add trailing slash to */wp-admin requests.
	rewrite /wp-admin\$ \$scheme://\$host\$uri/ permanent;

	location ~*  \.(jpg|jpeg|png|gif|css|js|ico)\$ {
		expires max;
		log_not_found off;
	}

	location ~ \.php\$ {
		try_files \$uri =404;
		fastcgi_pass unix:/var/run/php5-fpm-vagrant.sock;
		fastcgi_index index.php;
		fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
		include fastcgi_params;
	}
}

EOF

service nginx reload