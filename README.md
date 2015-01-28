hooktftp in a container!
========================

Project URL: [https://github.com/jumanjihouse/hooktftp-runtime](https://github.com/jumanjihouse/hooktftp-runtime)

Registry: [https://registry.hub.docker.com/u/jumanjiman/hooktftp/](https://registry.hub.docker.com/u/jumanjiman/hooktftp/)


Overview
--------

This source is used to build an image for
[hooktftp](https://github.com/epeli/hooktftp).

The primary artifact is a docker image with the `hooktftp` static binary
and a default, minimal configuration.
The runtime image is quite small (roughly 18 MB) since it is based on
[Alpine Linux](https://www.alpinelinux.org/).
I may support other userspaces in the future.

The goal is to provide a compromise between a single, monolithic
tftpd image that contains *all the things* and a flexible tftpd
image that contains *just enough* to combine with custom-built
data containers or volumes an organization needs to bootstrap
their infrastructure.


Build integrity and docker tags
-------------------------------

Build status (master branch): [![wercker status](https://app.wercker.com/status/6c7ea5ad3b7bc9759361ce22fbe00a91/s/master "wercker status")](https://app.wercker.com/project/bykey/6c7ea5ad3b7bc9759361ce22fbe00a91)

An unattended test harness runs the build script and acceptance tests.
If all tests pass on master branch in the unattended test harness,
wercker pushes the built image to the Docker hub.

The CI scripts on wercker apply two tags before pushing to docker hub:

* `jumanjiman/hooktftp:latest`: latest successful build on master branch
* `jumanjiman/hooktftp:<git-hash>`: a particular build on master branch

Therefore you can `docker pull` a specific tag if you don't want *latest*.

The build script adds a file to the image: `/root/wercker-build-url`.
This file contains the HTTPS URL for the wercker build of the image and
enables you to correlate a particular image to its tests on wercker.


How-to
------

### Fetch an already-built image

The runtime image is published as `jumanjiman/hooktftp`.

    docker pull jumanjiman/hooktftp


### List files in the image

The image contains the typical syslinux, efi, and pxelinux files
from **syslinux 6.0.3** at `/tftpboot/`.
List them with:

    docker run --rm -t \
      --entrypoint=/bin/sh \
      jumanjiman/hooktftp -c "find /tftpboot -type f"


### Configure and run

The container reads the config file `/etc/hooktftp/hooktftp.yml`
inside the container. You can use the default config provided
[inside the image](src/alpine/runtime/hooktftp.yml) or provide
your own at runtime.

The published image contains *just enough* files to provide
a base tftpd to PXE-boot your hosts to a simple menu.
The [simple menu](src/alpine/runtime/pxelinux.cfg/F1.msg) and
[pxelinux.cfg/default](src/alpine/runtime/pxelinux.cfg/default)
only allow to skip PXE.
Therefore you probably want to override the built-in menu.

Run a container with your own `pxelinux.cfg` files:

    docker run -d -p 69:69/udp \
      -v /path/to/your/pxelinux.cfg:/tftpboot/pxelinux.cfg:ro \
      jumanjiman/hooktftp

Run a container with default config and your data:

    docker run -d -p 69:69/udp \
      -v /path/to/your/files:/tftpboot:ro \
      jumanjiman/hooktftp

Run a container with your own config and your own data:

    docker run -d -p 69:69/udp \
      -v /path/to/your/files:/tftpboot:ro \
      -v /path/to/your/config/dir:/etc/hooktftp:ro \
      jumanjiman/hooktftp

Use multiple volumes to add site-local boot files and menus
in addition to the built-in syslinux files:

    docker run -d -p 69:69/udp \
      -v /path/to/your/pxelinux.cfg:/tftpboot/pxelinux.cfg:ro \
      -v /path/to/your/bootfiles:/tftpboot/site:ro \
      jumanjiman/hooktftp


### Build

The build script(s) produce multiple artifacts:

| Image Tag        | Size   | Purpose                        |
| :--------------- | -----: | :----------------------------- |
| hooktftp-builder | 400 MB | compile hooktftp static binary |
| hooktftp-runtime |  18 MB | run hooktftp as a service      |
| tftp             |   6 MB | test the runtime container     |

On a docker host, run:

    script/build
    script/test

If you want to do a timed build-and-test, run:

    script/timed-build-and-test


### Publish to a private registry

You can push the built image to a private docker registry:

    docker tag hooktftp-runtime registry_id/your_id/hooktftp
    docker push registry_id/your_id/hooktftp


Contribute
----------

See [`CONTRIBUTING.md`](CONTRIBUTING.md) in this repo.


License
-------

See [`LICENSE`](LICENSE) in this repo.
