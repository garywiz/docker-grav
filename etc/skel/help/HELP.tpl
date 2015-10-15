Help for Image: %(PARENT_IMAGE) Version %(IMAGE_VERSION) 
          Grav: Version %(GRAV_VERSION)
     Chaperone: %(`chaperone --version | awk '/This is/{print $5}'`)
         Linux: %(`cat /etc/issue | head -1 | sed -e 's/Welcome to //' -e 's/ \\.*$//'`)

This image contains contains a complete installation of the Grav Flat-File CMS, 
ready to use.  For more information, see http://getgrav.org.   For information
about how to use this image, see https://github.com/garywiz/docker-grav.

When you launch the container, the Grav site will be running at the URL:
   http://%(CONFIG_EXT_HOSTNAME)%(CONFIG_EXT_HTTP_PORT:|80||:%(CONFIG_EXT_HTTP_PORT))/
(Assuming you haven't changed the default port.)

You can extract also ready-made startup scripts for this image by running
the following command:

  $ docker run -i --rm %(PARENT_IMAGE) --task get-launcher | sh

Startup scripts have the option of working with attached storage.
Each script is self-documenting and has configuration variables
at the beginning of the script itself.
