#!/usr/bin/env bash

APP=$1
DOCROOT=$2
if [ "$APP" != "typo3" ]
then
	echo "No TYPO3 configuration selected."
	exit 0
fi

echo "Configuring nginx server block for TYPO3 ..."
cat > /etc/nginx/sites-available/vagrant <<EOF
server {
	listen 80;
	listen [::]:80;

	root /var/www/$DOCROOT;
	server_name _;

	index index.php;
	try_files \$uri \$uri/ index.php\$is_args\$args;

	location ~ \.php$ {
		try_files \$uri =404;
		include /etc/nginx/fastcgi_params;
		fastcgi_pass unix:/var/run/php5-fpm-vagrant.sock;
		fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
		fastcgi_index index.php;
	}

	location ~ /\.(js|css)\$ {
		expires 604800s;
	}

	if (!-e \$request_filename){
		rewrite ^/(.+)\.(\d+)\.(php|js|css|png|jpg|gif|gzip)\$ /\$1.\$3 last;
	}

	location ~* ^/fileadmin/(.*/)?_recycler_/ {
		deny all;
	}
	location ~* ^/fileadmin/templates/.*(\.txt|\.ts)\$ {
		deny all;
	}
	location ~* ^/typo3conf/ext/[^/]+/Resources/Private/ {
		deny all;
	}
	location ~* ^/(typo3/|fileadmin/|typo3conf/|typo3temp/|uploads/|favicon\.ico) {
	}

	location / {
		if (\$query_string ~ ".+") {
			return 405;
		}
		# pass requests from logged-in users to PHP
		if (\$http_cookie ~ 'nc_staticfilecache|be_typo_user|fe_typo_user' ) {
			return 405;
		} # pass POST requests to PHP
		if (\$request_method !~ ^(GET|HEAD)\$ ) {
			return 405;
		}
		if (\$http_pragma = 'no-cache') {
			return 405;
		}
		if (\$http_cache_control = 'no-cache') {
			return 405;
		}
		error_page 405 = @nocache;

		# serve requested content from the cache if available, otherwise pass the request to PHP
		try_files /typo3temp/tx_ncstaticfilecache/\$host\${request_uri}index.html @nocache;
	}

	location @nocache {
		try_files \$uri \$uri/ /index.php\$is_args\$args;
	}
}

EOF
service nginx reload