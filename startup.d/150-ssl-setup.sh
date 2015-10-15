#!/bin/bash

# Takes care of setting up SSL by generating a snakeoil key (self-signed) whenever 
# CONFIG_EXT_SSL_HOSTNAME is defined.   You'll need to reconfigure your webserver with
# actual keys if you want to serve https properly.

# Only if we have CONFIG_EXT_SSL_HOSTNAME...

if [ "$CONFIG_EXT_SSL_HOSTNAME" != "" ]; then

    # Generate testing certs if they aren't here.

    certpem=$VAR_DIR/certs/ssl-cert-grav-$CONFIG_EXT_SSL_HOSTNAME.crt
    certkey=$VAR_DIR/certs/ssl-cert-grav-$CONFIG_EXT_SSL_HOSTNAME.key

    if [ ! -f $certpem ]; then
	template="$APPS_DIR/etc/ssleay.cnf"

	# # should be a less common char
	# problem is that openssl virtually accepts everything and we need to
	# sacrifice one char.

	TMPFILE="$(mktemp)" || exit 1

	sed -e s#@HostName@#"$CONFIG_EXT_SSL_HOSTNAME"# $template > $TMPFILE

	# create the certificate.

	mkdir -p $VAR_DIR/certs

	openssl req -config $TMPFILE -new -x509 -days 3650 -nodes -out $certpem -keyout $certkey

	chmod 644 $certpem
	chmod 640 $certkey

	rm -rf $TMPFILE
    fi

fi
