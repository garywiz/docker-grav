# Grav Flat-File CMS Docker Image

Grav is a fast, simple, flexible web-platform.  This is a Docker image that makes it trivial to fire-up and use Grav.

To learn more about Grav, see the [Grav Website](http://learn.getgrav.org/basics/what-is-grav).

This image is [also available on Docker Hub](https://hub.docker.com/r/garywiz/docker-grav/) so you can pull it directly from there.  There's no need to build it yourself.

**NOTE**: This is an early-release of this container.   See the "Known Issues" section at the very bottom of this page for more information about things we know don't work.

The following documentation tells you how to use the `docker-grav` image, a lean full-featured Docker image that has the following features:

* Lean 100MB image with a pre-configured `nginx` server and a complete installation of Grav along with the [Grav Administration Plug-in](http://getgrav.org/blog/beta-admin-plugin-available) to make it easy to get started..
* Works both as a self-contained image, or will automatically recognize attached storage devices so that persistent Grav data is not stored in the container.  Makes it easy to upgrade when new images are released.
*  Fully configurable using environment variables, including options for logging, and initial Grav setup.  A fully customized container can be started without the need to build a new image.
* Automatically generates a self-signed SSL certificate matched to your domain, or allows you to easily add your own legitimate SSL certificate.

## Quick Start

You can get started quickly using the image hosted on Docker Hub.  For example, to quickly create a running self-contained Grav server daemon:

    $ docker pull garywiz/docker-grav
    $ docker run -d -p 8080:8080 garywiz/docker-grav

Within a few seconds, you should be able to use Grav by going to `http://localhost:8080/`.    The default login user is `admin` with a password of `ChangeMe`.   (See "Customizing Grav" below for information about how to modify or add new users.

If you want to store the Grav website and configuration locally outside the image, you can use the built-in launcher script.   Extract the launcher script from the image like this:

    $ docker run -i --rm garywiz/docker-grav --task get-launcher | sh

This will create a flexible launcher script that you can customize or use as a template.  You can run it as a daemon:

    $ ./run-docker-grav.sh -d

Or, if you want to have local persistent storage:

    $ mkdir docker-grav-storage
    $ ./run-docker-grav.sh -d

Now, all persistent data will be stored in the `docker-grav-storage` directory.  The container itself is therefore entirely disposable.

The `run-docker-grav.sh` script is designed to be self-documenting and you can edit it to change start-up options and storage options.  You can get up-to-date help on the image's features like this:

    $ docker run -i --rm garywiz/docker-grav --task get-help

## Using `run-docker-grav.sh`

If you extract the default launcher (see above), it can serve as the basis for your own start-up script.  But, it also has some default options built-in to make it easy to tailor startup without having to modify the script.  You can use the `-h` option to get a list of options:

    $ ./run-docker-grav.sh -h
    Usage: run-docker-grav.sh [-d] [-p port#] [-h]
           Run Grav from garywiz/docker-grav as a daemon (with -d) or 
           interactively (the default).
    
      -d            Run as daemon (otherwise interactive)
      -p port#      Specify port number to expose Grav server (default 8080)
      -s dirpath    Specifies the path to an optional storage directory where 
                    ALL persistent Grav files and settings will be stored.  This allows
                    you to keep your site separate from the container so you can easily
                    upgrade the container software. By default, this script looks to see 
                    if ../docker-grav-storage exists, and if it does, it will be used.  
                    You can override that default with this switch.
      -n name       Name the container 'name' instead of the default name invented by Docker.
    
    HTTPS options (SSL):
      -H sslhost    Specify the SSL host name and enable the SSL server.  If specified, Grav
                will also be available using https on the port specified by -P
      -P sslport#   Specify SSL port number (default 8443)

## Customizing Grav

If you run the Grav container using the above launcher but omit the `-d` switch, you'll be place into the container in an interactive shell where you can use the `grav` and `gpm` command to customize Grav by adding users, themes, or plugins:

        $ ./run-docker-grav.sh
        Oct 15 22:08:28 e265699abf5f chaperone[1]: system will be killed when '/bin/bash' exits
        Now running inside container. Directory is: /apps

        Your Grav site is running at http://localhost:8080/
        
        The Grav 'gpm' and 'grav' commands are available at the prompt.
        bash-4.3$ gpm
        Grav Package Manager version 0.9.45
        ...

You can use `gpm` [as described here in the Grav documentation](http://learn.getgrav.org/advanced/grav-cli) to install new features or browse around a the installation.   The container will run and be usable until you exit, at which point it will be destroyed.    This is generally a good way to experiment.

 **Note**: Any features you add will be local to the container unless you use persistent storage as described below under "Configuring Attached Storage". 

Once you've configured attached storage, your entire Grav configuration will be located in the attached storage `var/grav` subdirectory.   There you will find the `system.yaml` and `site.yaml` file.  You can change these and re-run your container and they'll persist even if they container is destroyed.

See the [Grav Configuration documentation](http://learn.getgrav.org/basics/grav-configuration) for more information about how to modify these files.
        
## Full Option List

If you want to invent your own start-up, or are using an orchestration tool, here is a quick view of all the configuration options piled into one command along with their defaults:

    $ docker run -d garywiz/docker-grav \
      -p 8080:8080 \
      -e CONFIG_LOGGING=stdout \
      -e CONFIG_ADMIN_USER=admin \
      -e CONFIG_ADMIN_PASSWORD=ChangeMe \
      -e CONFIG_ADMIN_EMAIL="nobody@nowhere.com" \
      -e CONFIG_ADMIN_NAME="Grav Administrator" \
      -e CONFIG_ADMIN_TITLE="Grav Administrator" \
      -e CONFIG_EXT_SSL_HOSTNAME=""

* **`CONFIG_LOGGING`**: Either `stdout` (the default), `file`, or `syslog:host` (see "Logging Configuration" below).
* **`CONFIG_ADMIN_USER`**, **`CONFIG_ADMIN_USER`**, **`CONFIG_ADMIN_USER`**, and **`CONFIG_ADMIN_USER`**: Specifies the user credentials for the Administrative plugin interface account.  This account will be set up automatically to have full access, but won't be changed if it already exists.   You can disable this completely by setting `CONFIG_ADMIN_USER` to the string "none".
* **`CONFIG_EXT_SSL_HOSTNAME`**: This is the name of the SSL host.  It should match the actual hostname people will use to access the server.  If set to "blank", then Grav will run using standard HTTP.  If you set this, you also need to add `-p 8443:8443` to the command line to expose the `https` port.

Of course, you can customize this set-up exactly like any other Docker run command, remapping ports or using other options however you wish.   If you want to run interactively, you'll  need to include a final argument such as `/bin/bash` as well as use the `-i` and `-t` options.  See the [Docker run CLI reference](https://docs.docker.com/reference/commandline/run/) for further information.

## Configuring Attached Storage

Using attached storage, you can make choose a location for the Grav user files and configuration so that your entire persistent state is stored outside the container itself.  This makes it easy to update the container to a new version while retaining your existing content and configuration.

When configuring attached storage, there are two considerations:

1.  Attached storage must be mounted at `/apps/var` inside the container, whether using the Docker `-v` switch, or `--volumes-from`.
2. You will need to tell the container to match the user credentials using the `--create-user` switch ([documented here on the Chaperone site](http://garywiz.github.io/chaperone/ref/command-line.html#option-create-user)).

Both are pretty easy.  For example, assume you are going to store persistent data on your local drive in `/persist/gravsite`.   Providing the directory exists, you can just do this:

    $ docker run -d -v /persist/gravsite:/apps/var garywiz/docker-grav \
         --create-user anyuser:/apps/var

When the container starts, it will assure that all internal services run as a new user called `anyuser` whose UID/GID credentials match the credentials your host box has assigned to `/persist/gravsite`.

That's it!

When you run the container, you'll see that all the Grav persistent data files have been properly created in `/persist/gravsite`.

## Logging Configuration

By default, all container logs will be sent to `stdout` and can be viewed using the `docker logs` command.

If this isn't suitable, there are two additional options that can be specified using the `CONFIG_LOGGING` environment variable:

**`CONFIG_LOGGING="file"`** - This setting will cause all logging information to be sent to `var/log/syslog.log` either inside the container or on attached storage.

**`CONFIG_LOGGING="syslog:hostname"`** - In this case, you need to specify `hostname` as the destination for logging.  The specified host must have a syslog-compatible daemon running on UDP port 514.

## Using Your Own SSL Keys

By default, a self-signed SSL key will be generated automatically for you at start-up if you enable SSL.  If attached storage is used, the key will be generated only once.  Otherwise, a new key will be created each time a new container starts.

Most enterprise and production installations will often want to use their own pre-defined key.  In order to do so, you'll need to:

1.  Run this image using attached storage.  This is where you will store your keys, and they will persist when you upgrade the container.
2. Have your certificate and private key files in standard `PEM` format (the one usually used by Certificate authorities), or convert it from PKCS12 format as described below.
3. Not be an SSL noob.  I hate to say it, but it really helps if you've done this before.

Here is a step-by-step guide.

#### Run with Persistent Storage

This is easy if you're using the provided launcher, as described above.  The first thing to do is run the container once just to initialize the persistent storage directory:

    $ mkdir docker-grav-storage
        $ ./run-docker-grav.sh -d
    Using attached storage at .../docker-grav-storage
    00e9615bc51d63f9a150186482b3258d1c24b4f21ca0c781ae6e1717d9c97abc
    $

Now that your container is running, you should see the following in `docker-grav-storage`:

    $ cd docker-grav-storage
    $ ls
    certs config grav log run
    $

Certificates are stored in the `certs` directory:

    $ cd certs
    $ ls
    ssl-cert-localhost.crt  ssl-cert-localhost.key
    $

The self-signed certificates is the file ending with `.crt` and the private key is the one ending with `.key`.

Once you see that these are present, it's probably a good idea to stop (and even delete) your container, as all persistent data is now stored in `docker-grav-storage`.

#### Replace the keys with your own

Note that the names of the certificate and keys will always look like this: `ssl-cert-<hostname>.crt`, where `<hostname>` will be the exact string you used with the `CONFIG_EXT_SSL_HOSTNAME` environment variable. 

So, if your site is going to be `https://grav.example.com`, then make sure you edit your start-up scripts to change the hostname, then make sure your certificate and key files are correctly named as follows:

    ssl-cert-grav.example.com.crt
    ssl-cert-grav.example.com.key

If your keys are not already in `PEM` format, you may need to convert them using SSL as [this StackOverflow answer describes for PKCS12 keys](http://stackoverflow.com/questions/15144046/need-help-converting-p12-certificate-into-pem-using-openssl).

#### Re-run the container

Once you've replaced the certificates, you can simply restart the old container, or create a new container using the same attached storage location.  Your new certificate will then be in use.

## Known Issues

* There is no email service installed within the container, so anything which sends email (such as the forgotten password feature) do not currently work.
* There are many Grav plugins, very few of which have been tested.
* When using attached storage, any newly installed plugins will be stored in attached storage rather inside the image.  The admin plugin and related plugins, however, are stored inside the container so that upgrading the container will upgrade the entire set of administrative plugins as well.
