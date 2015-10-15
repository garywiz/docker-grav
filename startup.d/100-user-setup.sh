#!/bin/bash

# Sets up CONFIG_ADMIN_USER, if it exists

function dolog() { logger -t 100-user-setup.sh -p info $*; }

[ "$CONFIG_ADMIN_USER" == "" ] && exit

CONF_DIR="$APPS_DIR/www/grav/user/accounts"
CONF_FILE="$CONF_DIR/$CONFIG_ADMIN_USER.yaml"

[ -f "$CONF_FILE" ] && exit

# No such file, create it now.

mkdir -p $CONF_DIR
phash=$(echo '<?php echo password_hash(getenv("CONFIG_ADMIN_PASSWORD"), PASSWORD_DEFAULT); ?>' | php)

cat >$CONF_FILE <<EOF
email: $CONFIG_ADMIN_EMAIL
access:
  admin:
    login: true
    super: true
  site:
    login: true
fullname: $CONFIG_ADMIN_NAME
title: $CONFIG_ADMIN_TITLE
hashed_password: $phash
EOF

dolog "created new grav administrative user: $CONFIG_ADMIN_USER"
