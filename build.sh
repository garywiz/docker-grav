#!/bin/bash
# Builds a new docker-grav image

# the cd trick assures this works even if the current directory is not current.
cd ${0%/*}
if [ "$CHAP_SERVICE_NAME" != "" ]; then
  echo You need to run build.sh on your docker host, not inside a container.
  exit
fi

# Uncomment to default to your new derivative image name...
prodimage="garywiz/docker-grav"

[ "$1" != "" ] && prodimage="$1"

if [ "$prodimage" == "" ]; then
  echo "Usage: ./build.sh <production-image-name>"
  exit 1
else
  echo Building "$prodimage" ...
fi

if [ ! -f Dockerfile ]; then
  echo "Expecting to find Dockerfile in $PWD ... not found!"
  exit 1
fi

# Do the build
docker build -t $prodimage .
