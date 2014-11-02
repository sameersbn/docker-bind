# Table of Contents
- [Introduction](#introduction)
- [Contributing](#contributing)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Data Store](#data-store)
- [Upgrading](#upgrading)

# Introduction
Dockerfile to build a bind dns server image with webmin for easy configuration.

# Contributing

If you find this image useful here's how you can help:

- Send a Pull Request with your awesome new features and bug fixes
- Help new users with [Issues](https://github.com/sameersbn/docker-bind/issues) they may encounter
- Send me a tip on [Gittip](https://gittip.com/sameersbn/) or using Bitcoin at **16rDxVqJPyYAFYPLduTaSiwe7ZiY1hHqKM**

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

Point your browser to `https://localhost:10000` and login as root. A random password is assigned for the root user. This password can be retrieved from the container logs.

```bash
docker logs bind 2>&1 | grep '^User: ' | tail -n1
```

Please note that the password is not persistent and changes every time the image is executed.

# Data Store
You should mount a volume at `/data` for persistence of your bind server configuration.

```
docker run --name='bind' -d -p 53:53/udp -p 10000:10000 \
-v /opt/bind:/data sameersbn/bind:latest
```

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
