# This is a template Dockerfile for creating a new image.  
# See the README for a complete description of how you create derivative images.

FROM chapdev/alpine-nginx-php
ADD . /setup/

# Git tag version number format should the same as below.
ENV GRAV_VERSION=1.0.4

RUN /setup/build/install.sh
