[![Circle CI](https://circleci.com/gh/sameersbn/docker-bind.svg?style=svg)](https://circleci.com/gh/sameersbn/docker-bind)

# Table of Contents

- [Introduction](#introduction)
- [Contributing](#contributing)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Data Store](#data-store)
- [Shell Access](#shell-access)
- [Upgrading](#upgrading)

# Introduction

Dockerfile to build a bind dns server image with webmin for easy configuration.

# Contributing

If you find this image useful here's how you can help:

- Send a Pull Request with your awesome new features and bug fixes
- Help new users with [Issues](https://github.com/sameersbn/docker-bind/issues) they may encounter
- Support the development of this image with a [donation](http://www.damagehead.com/donate/)

# Installation

Pull the latest version of the image from the docker index. This is the recommended method of installation as it is easier to update image in the future. These builds are performed by the **Docker Trusted Build** service.

```
docker pull sameersbn/bind:latest
```

Alternately you can build the image yourself.

```
git clone https://github.com/sameersbn/docker-bind.git
cd docker-bind
docker build -t="$USER/bind" .
```

# Quick Start

Run the image

```
docker run --name='bind' -d -p 53:53/udp -p 10000:10000 \
sameersbn/bind:latest
```

By default, the container will start webmin where you can configure bind using the web interface. Point your browser to `https://localhost:10000` and login as root. A random password is assigned for the root user. This password can be retrieved from the container logs.

```bash
docker logs bind 2>&1 | grep '^User: ' | tail -n1
```

Please note that the password is not persistent and changes every time the image is executed.

If you do not want the webmin server to be started, you can specify `-e WEBMIN_ENABLED=false` in the docker command line.

If you do not want a random password for the root user, you can specify it using the `ROOT_PASSWORD` configuration option, eg. `-e ROOT_PASSWORD=password`. Please note that the root password is only set if `WEBMIN_ENABLED=true`.

# Data Store
You should mount a volume at `/data` for persistence of your bind server configuration.

```
docker run --name='bind' -d -p 53:53/udp -p 10000:10000 \
-v /opt/bind:/data sameersbn/bind:latest
```

# Shell Access

For debugging and maintenance purposes you may want access the containers shell. If you are using docker version `1.3.0` or higher you can access a running containers shell using `docker exec` command.

```bash
docker exec -it bind bash
```

If you are using an older version of docker, you can use the [nsenter](http://man7.org/linux/man-pages/man1/nsenter.1.html) linux tool (part of the util-linux package) to access the container shell.

Some linux distros (e.g. ubuntu) use older versions of the util-linux which do not include the `nsenter` tool. To get around this @jpetazzo has created a nice docker image that allows you to install the `nsenter` utility and a helper script named `docker-enter` on these distros.

To install `nsenter` execute the following command on your host,

```bash
docker run --rm -v /usr/local/bin:/target jpetazzo/nsenter
```

Now you can access the container shell using the command

```bash
sudo docker-enter bind
```

For more information refer https://github.com/jpetazzo/nsenter

# Upgrading

To upgrade to newer releases, simply follow this 3 step upgrade procedure.

- **Step 1**: Update the docker image.

```
docker pull sameersbn/bind:latest
```

- **Step 2**: Stop the currently running image

```
docker stop bind
```

- **Step 3**: Start the image

```
docker run -name bind -d [OPTIONS] sameersbn/bind:latest
```
