# DO NOT MODIFY THIS FILE.  IT WILL BE REGENERATED EVERY TIME THE CONTAINER STARTS

server {
    listen 8080;
    server_name .%(CONFIG_EXT_HOSTNAME) "";

    root %(NGINX_SITES_DIR)/grav;

    access_log %(NGINX_LOG_DIR)/grav.access.log;
    error_log syslog:server=unix:/dev/log;

    error_page 500 502 503 504 /50x.html;

    location = /50x.html {
	root html;
    }

    location / {
        root %(NGINX_SITES_DIR)/grav;
	index index.php;
	if (!-e $request_filename){ rewrite ^(.*)$ /index.php last; }
    }

    # if you want grav in a sub-directory of your main site
    # (for example, example.com/mygrav) then you need this rewrite:
    location /mygrav {
	if (!-e $request_filename){ rewrite ^(.*)$ /mygrav/$2 last; }
	try_files $uri $uri/ /index.php?$args;
    }

    # if using grav in a sub-directory of your site,
    # prepend the actual path to each location
    # for example: /mygrav/images
    # and: /mygrav/user
    # and: /mygrav/cache
    # and so on

    location /images/ {
	# Serve images as static
    }

    location /user {
	rewrite ^/user/accounts/(.*)$ /error redirect;
	rewrite ^/user/config/(.*)$ /error redirect;
	rewrite ^/user/(.*)\.(txt|md|html|php|yaml|json|twig|sh|bat)$ /error redirect;
    }

    location /cache {
	rewrite ^/cache/(.*) /error redirect;
    }

    location /bin {
	rewrite ^/bin/(.*)$ /error redirect;
    }

    location /backup {
	rewrite ^/backup/(.*) /error redirect;
    }

    location /system {
	rewrite ^/system/(.*)\.(txt|md|html|php|yaml|json|twig|sh|bat)$ /error redirect;
    }

    location /vendor {
	rewrite ^/vendor/(.*)\.(txt|md|html|php|yaml|json|twig|sh|bat)$ /error redirect;
    }

    # Remember to change 127.0.0.1:9000 to the Ip/port
    # you configured php-cgi.exe to run from

    location ~ \.php$ {
	try_files $uri =404;
        include %(VAR_DIR)/sites.d/php-fast.inc;
	fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_index index.php;
	fastcgi_param PATH_INFO      $fastcgi_path_info;
    }
}

%(CONFIG_EXT_SSL_HOSTNAME:|?*|
# SSL Configuration for %(CONFIG_EXT_SSL_HOSTNAME)

server {
	# .domain.com will match both domain.com and anything.domain.com
	server_name .%(CONFIG_EXT_SSL_HOSTNAME) "";
	listen 8443;
 
	ssl on;
	ssl_certificate %(VAR_DIR)/certs/ssl-cert-grav-%(CONFIG_EXT_SSL_HOSTNAME).crt;
	ssl_certificate_key %(VAR_DIR)/certs/ssl-cert-grav-%(CONFIG_EXT_SSL_HOSTNAME).key;
	
	root %(NGINX_SITES_DIR)/grav;
 
	access_log %(NGINX_LOG_DIR)/grav-ssl.access.log;
	error_log syslog:server=unix:/dev/log;
 
    error_page 500 502 503 504 /50x.html;

    location = /50x.html {
	root html;
    }

    location / {
        root %(NGINX_SITES_DIR)/grav;
	index index.php;
	if (!-e $request_filename){ rewrite ^(.*)$ /index.php last; }
    }

    # if you want grav in a sub-directory of your main site
    # (for example, example.com/mygrav) then you need this rewrite:
    location /mygrav {
	if (!-e $request_filename){ rewrite ^(.*)$ /mygrav/$2 last; }
	try_files $uri $uri/ /index.php?$args;
    }

    # if using grav in a sub-directory of your site,
    # prepend the actual path to each location
    # for example: /mygrav/images
    # and: /mygrav/user
    # and: /mygrav/cache
    # and so on

    location /images/ {
	# Serve images as static
    }

    location /user {
	rewrite ^/user/accounts/(.*)$ /error redirect;
	rewrite ^/user/config/(.*)$ /error redirect;
	rewrite ^/user/(.*)\.(txt\|md\|html\|php\|yaml\|json\|twig\|sh\|bat)$ /error redirect;
    }

    location /cache {
	rewrite ^/cache/(.*) /error redirect;
    }

    location /bin {
	rewrite ^/bin/(.*)$ /error redirect;
    }

    location /backup {
	rewrite ^/backup/(.*) /error redirect;
    }

    location /system {
	rewrite ^/system/(.*)\.(txt\|md\|html\|php\|yaml\|json\|twig\|sh\|bat)$ /error redirect;
    }

    location /vendor {
	rewrite ^/vendor/(.*)\.(txt\|md\|html\|php\|yaml\|json\|twig\|sh\|bat)$ /error redirect;
    }

    # Remember to change 127.0.0.1:9000 to the Ip/port
    # you configured php-cgi.exe to run from

    location ~ \.php$ {
	try_files $uri =404;
        include %(VAR_DIR)/sites.d/php-fast.inc;
	fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_index index.php;
	fastcgi_param PATH_INFO      $fastcgi_path_info;
    }
}
|)
