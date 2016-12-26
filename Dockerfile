# This is a template Dockerfile for creating a new image.  
# See the README for a complete description of how you create derivative images.

FROM chapdev/alpine-nginx-php
ADD . /setup/

# Git tag version number format should the same as below.
ENV GRAV_VERSION=1.1.11

RUN /setup/build/install.sh
