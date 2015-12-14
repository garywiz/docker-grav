#!/bin/bash
#Extracted from %(PARENT_IMAGE) on %(`date`)

# Usage is displayed if you use -h

usage() {
  echo "Usage: %(DEFAULT_LAUNCHER) [-d] [-p port#] [-h]"
  echo "       Run Grav from $IMAGE as a daemon (with -d) or interactively (the default)."
  echo ""
  echo "  -d            Run as daemon (otherwise interactive)"
  echo "  -p port#      Specify port number to expose Grav server (default 8080)"
  echo "  -s dirpath    Specifies the path to an optional storage directory where ALL persistent"
  echo "                Grav files and settings will be stored.  This allows you to keep your site"
  echo "                separate from the container so you can easily upgrade the container software."
  echo "                By default, this script looks to see if $STORAGE_LOCATION exists, and"
  echo "                if it does, it will be used.  You can override that default with this switch."
  echo "  -n name       Name the container 'name' instead of the default name invented by Docker."
  echo ""
  echo "HTTPS options (SSL):"
  echo "  -H sslhost    Specify the SSL host name and enable the SSL server.  If specified, Grav"
  echo "                will also be available using https on the port specified by -P"
  echo "  -P sslport#   Specify SSL port number (default 8443)"
  exit
}

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

# If this directory exists and is writable, then it will be used
# as attached storage.
# You can change STORAGE_LOCATION to anything you wish other than the default below.

STORAGE_LOCATION="$PWD/%(IMAGE_BASENAME)-storage"
STORAGE_USER="$USER"

# Parse the command line and override any options provided above

docker_opt=""

while getopts ":-dp:n:s:H:P:" o; do
  case "$o" in
    d)
      INTERACTIVE_SHELL=""
      ;;
    n)
      docker_opt="$docker_opt --name $OPTARG"
      ;;
    p)
      EXT_HTTP_PORT="$OPTARG"
      ;;      
    P)
      EXT_HTTPS_PORT="$OPTARG"
      ;;      
    H)
      EXT_SSL_HOSTNAME="$OPTARG"
      ;;      
    s)
      # The path must exist, and we need the full path if it's relative...
      [ -d "$OPTARG" ] && STORAGE_LOCATION="$(cd "$(dirname "$OPTARG")"; pwd)/$(basename "$OPTARG")"
      ;;
    -) # first long option terminates so remaining options go to Chaperone
      break
      ;;
    *)
      usage
      ;;
  esac
done
shift $((OPTIND-1))

# Docker port options (derive from above)

PORTOPT="-p $EXT_HTTP_PORT:8080 -p $EXT_HTTPS_PORT:8443"

# The rest should be OK...

if [ "$INTERACTIVE_SHELL" != "" ]; then
  docker_opt="$docker_opt -t -i -e TERM=$TERM --rm=true"
else
  docker_opt="-d"
fi

docker_opt="$docker_opt $PORTOPT \
  -e EMACS=$EMACS \
  -e CONFIG_EXT_HOSTNAME=$EXT_HOSTNAME \
  -e CONFIG_EXT_HTTPS_PORT=$EXT_HTTPS_PORT \
  -e CONFIG_EXT_HTTP_PORT=$EXT_HTTP_PORT \
  -e CONFIG_ADMIN_USER=$ADMIN_USER \
  -e CONFIG_ADMIN_PASSWORD=$ADMIN_PASSWORD \
  -e CONFIG_ADMIN_EMAIL=$ADMIN_EMAIL \
  -e CONFIG_LOGGING=file"

[ "$EXT_SSL_HOSTNAME" != "" ] && docker_opt="$docker_opt -e CONFIG_EXT_SSL_HOSTNAME=$EXT_SSL_HOSTNAME"

if [ "$STORAGE_LOCATION" != "" -a -d "$STORAGE_LOCATION" -a -w "$STORAGE_LOCATION" ]; then
  SELINUX_FLAG=$(sestatus 2>/dev/null | fgrep -q enabled && echo :z)
  docker_opt="$docker_opt -v $STORAGE_LOCATION:/apps/var$SELINUX_FLAG"
  chap_opt="--create $STORAGE_USER:/apps/var"
  echo Using attached storage at $STORAGE_LOCATION
fi

docker run $docker_opt $IMAGE $chap_opt $* $INTERACTIVE_SHELL
