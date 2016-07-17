#!/bin/bash

# Set up a new $VAR_DIR/grav directory containing all writable components.
#
# If a var/grav directory doesn't exist, looks for any directories called grav/xxxx-dist, which are
# templates for how things should be set up in var.   Creates them, as well as the symbolic links
# which point to them.

VAR_GRAV=$VAR_DIR/grav

# bash functions

function dolog() { logger -t 050-grav-setup.sh -p info $*; }
function relpath() { python3 -c "import os,sys;print(os.path.relpath(*(sys.argv[1:])))" "$@"; }

# First, initialize all the necessary sub directories

cd $APPS_DIR/www/grav  # do all work from here

if [ ! -d $VAR_GRAV ]; then

  mkdir -p $VAR_GRAV
  for sf in $( find . -maxdepth 1 -type d -name '*-dist' ); do
    symlink=${sf/-dist}
    vardest=$VAR_GRAV${symlink/\./}
    cp -dR  $sf $vardest
    dolog "created $vardest"
  done

  # Now, for the sticky plugins, link back to the originals
  # These plugins will always refer back to the ones which shipped
  # with the container.  Other plugins can be installed within the user's
  # attached storage

  pushd $VAR_GRAV/user; mkdir plugins; cd plugins
  for sf in $APPS_DIR/www/grav/plugins-sticky/*; do
    ln -nsf $(relpath $sf)
  done
  popd

fi

# We have to (re)create the container symlinks if this is the
# first time we are preparing this container.

if [ "$CONTAINER_INIT" == "1" ]; then

  for sf in $( find . -maxdepth 1 -type d -name '*-dist' ); do
    symlink=${sf/-dist}
    vardest=$VAR_GRAV${symlink/\./}
    if [ -w . ]; then
      ln -nsf $(relpath $vardest) $symlink
    else
      sudo ln -nsf $(relpath $vardest) $symlink
    fi
  done

fi
