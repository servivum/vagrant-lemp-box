#!/usr/bin/env bash

APP=$1
DOCROOT=$2
if [ "$APP" != "symfony" ]
then
	echo "No Symfony configuration selected."
	exit 0
fi

echo "Loading Symfony installer ..."
curl -LsS http://symfony.com/installer -o /usr/local/bin/symfony
chmod a+x /usr/local/bin/symfony

echo "Configuring nginx server block for Symfony ..."
cat > /etc/nginx/sites-available/vagrant <<EOF
# Use for enforcing https
#server {
#	listen 80;
#	listen [::]:80;
#
#	server_name _;
#
#	return 301 https://$server_name$request_uri;
#}
server {
        #listen 443 ssl;
        listen 80;
        listen [::]:80;

        root /var/www/$DOCROOT/web;
        server_name _;

        #SSL certificate
        #ssl_certificate /etc/ssl/certs/certificate.crt;
        #ssl_certificate_key /etc/ssl/private/key.key;

        #HSTS
        #add_header Strict-Transport-Security max-age=15768000;

        location / {
                # try to serve file directly, fallback to app.php
                try_files \$uri /app.php\$is_args\$args;
        }

        location ~ ^/app\.php(/|\$) {
                fastcgi_pass unix:/var/run/php5-fpm-vagrant.sock;

                fastcgi_split_path_info ^(.+\.php)(/.*)\$;
                include fastcgi_params;
                fastcgi_param DOCUMENT_ROOT /var/www/$DOCROOT/web;
                fastcgi_param SCRIPT_FILENAME /var/www/$DOCROOT/web\$fastcgi_script_name;
                #fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
                # Prevents URIs that include the front controller. This will 404:
                # http://domain.tld/app.php/some-path
                # Remove the internal directive to allow URIs like this
                internal;
        }

        location ~ /\.ht {
                deny all;
        }
}
EOF
service nginx reload

echo "Setting timezone for php-cli to avoid Symfony warnings ..."
sed -i "s/^;date.timezone =$/date.timezone = \"Europe\/Berlin\"/" /etc/php5/cli/php.ini

# @ TODO: Set environment variable for defining dev mode.
#cat > /etc/php5/fpm/pool.d/vagrant.conf <<EOF
#        env[SYMFONY__] = /tmp
#EOF
#service php5-fpm reload