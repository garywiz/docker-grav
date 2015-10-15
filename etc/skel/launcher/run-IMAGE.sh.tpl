#!/bin/bash
#Extracted from %(PARENT_IMAGE) on %(`date`)

# Run as interactive: ./%(DEFAULT_LAUNCHER) [options]
#          or daemon: ./%(DEFAULT_LAUNCHER) -d [options]

IMAGE="%(PARENT_IMAGE)"
INTERACTIVE_SHELL="/bin/bash"

# You can specify the external host and ports for Grav here.  Note that the HTTPS site
# will be started only if you uncomment EXT_SSL_HOSTNAME below (the certificate needs a hostname)

EXT_HOSTNAME=%(CONFIG_EXT_HOSTNAME:-localhost)
EXT_HTTP_PORT=%(CONFIG_EXT_HTTP_PORT:-8080)
EXT_HTTPS_PORT=%(CONFIG_EXT_HTTPS_PORT:-8443)

# Uncomment to enable SSL and specify the certificate hostname

#EXT_SSL_HOSTNAME=secure.example.com

# Upon start-up, the container will create a new administrative user if one does not already
# exist with the given name.   To disable this, set ADMIN_USER to the string 'none'.

ADMIN_USER=admin
ADMIN_PASSWORD=ChangeMe
ADMIN_EMAIL="nobody@nowhere.com"

# Docker port options

PORTOPT="-p $EXT_HTTP_PORT:8080 -p $EXT_HTTPS_PORT:8443"

# If this directory exists and is writable, then it will be used
# as attached storage.
# You can change STORAGE_LOCATION to anything you wish other than the default below.

STORAGE_LOCATION="$PWD/%(IMAGE_BASENAME)-storage"
STORAGE_USER="$USER"

# The rest should be OK...

if [ "$1" == '-d' ]; then
  shift
  docker_opt="-d $PORTOPT"
  INTERACTIVE_SHELL=""
else
  docker_opt="-t -i -e TERM=$TERM --rm=true $PORTOPT"
fi

docker_opt="$docker_opt \
  -e EMACS=$EMACS \
  -e CONFIG_EXT_HOSTNAME=$EXT_HOSTNAME \
  -e CONFIG_EXT_HTTPS_PORT=$EXT_HTTPS_PORT \
  -e CONFIG_EXT_HTTP_PORT=$EXT_HTTP_PORT \
  -e CONFIG_ADMIN_USER=$ADMIN_USER \
  -e CONFIG_ADMIN_PASSWORD=$ADMIN_PASSWORD \
  -e CONFIG_ADMIN_EMAIL=$ADMIN_EMAIL"

[ "$EXT_SSL_HOSTNAME" != "" ] && docker_opt="$docker_opt -e CONFIG_EXT_SSL_HOSTNAME=$EXT_SSL_HOSTNAME"

if [ "$STORAGE_LOCATION" != "" -a -d "$STORAGE_LOCATION" -a -w "$STORAGE_LOCATION" ]; then
  SELINUX_FLAG=$(sestatus 2>/dev/null | fgrep -q enabled && echo :z)
  docker_opt="$docker_opt -v $STORAGE_LOCATION:/apps/var$SELINUX_FLAG"
  chap_opt="--create $STORAGE_USER:/apps/var"
  echo Using attached storage at $STORAGE_LOCATION
fi

docker run $docker_opt $IMAGE $chap_opt $* $INTERACTIVE_SHELL
