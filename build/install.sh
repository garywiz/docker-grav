#!/bin/bash

# Set in Dockerfile
#GRAV_VERSION=1.0.0-rc.4

cd /setup

# remove existing chaperone.d and startup.d from /apps so none linger
rm -rf /apps; mkdir /apps

# copy everything from setup to the root /apps except Dockerfile rebuild materials
echo copying application files to /apps ...
tar cf - --exclude ./build \
         --exclude ./build.sh \
    	 --exclude ./www/grav \
         --exclude ./var \
         --exclude ./run.sh . | (cd /apps; tar xf -)

# update the version information
sed "s/^GRAV_VERSION=.*/GRAV_VERSION=${GRAV_VERSION}/" </setup/etc/version.inc >/apps/etc/version.inc

# / is normally the user home directory for self-contained and attached-storage modes
ln -sf /apps/bash.bashrc /.bashrc

# PHP EXTENSIONS!
#
# Add any php extensions your application needs.  Alpine Linux is VERY granular and
# does not contain the large number of extensions you'd expect in a Ubuntu/Debian/CentOS
# install.  You can find the package names here...
# https://pkgs.alpinelinux.org/packages?name=php-%25&repo=all&arch=x86_64&maintainer=all

apk --update-cache add \
    php-ctype \
    php-curl \
    php-dom \
    php-gd \
    php-iconv \
    php-json \
    php-mcrypt \
    php-openssl \
    php-posix \
    php-sockets \
    php-xml \
    php-xmlreader \
    php-zip \
    && apk upgrade

mkdir -p /setup/grav; cd /setup/grav
wget https://github.com/getgrav/grav/releases/download/$GRAV_VERSION/grav-admin-v$GRAV_VERSION.zip
cd /apps/www
unzip -q /setup/grav/grav-admin-v$GRAV_VERSION.zip
mv grav-admin grav

# Move any writable directories to have -dist extensions.  See ../startup.d/050-grav-setup.sh for how this
# works when a container is started
cd grav

mv cache cache-dist
mv backup backup-dist
mv logs logs-dist
mv user user-dist; mv user-dist/plugins plugins-sticky
mv assets assets-dist
mv images images-dist

# Add additional setup commands for your production image here, if any.
# ...

# Clean up and assure permissions are correct

rm -rf /setup
chown -R runapps: /apps    # for full-container execution
