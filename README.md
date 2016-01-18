hooktftp in a container!
========================

Project URL: [https://github.com/jumanjihouse/hooktftp-runtime](https://github.com/jumanjihouse/hooktftp-runtime)

Registry: [https://registry.hub.docker.com/u/jumanjiman/hooktftp/](https://registry.hub.docker.com/u/jumanjiman/hooktftp/)


Overview
--------

This source is used to build an image for
[hooktftp](https://github.com/epeli/hooktftp).

The primary artifact is a docker image with the `hooktftp` binary
and a default, minimal configuration.
The runtime image is quite small since it is based on
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


### Load NetFilter modules

Add helpers to track connections:

    sudo modprobe nf_conntrack_tftp
    sudo modprobe nf_nat_tftp


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


### Use systemd for automatic startup

Review and potentially modify the sample systemd unit file at
[`systemd/hooktftp.service`](systemd/hooktftp.service), then run:

    sudo cp systemd/hooktftp.service /etc/systemd/system/
    sudo systemctl daemon-reload
    sudo systemctl start hooktftp
    sudo systemctl enable hooktftp


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

You can also test via the docker remote API if you have configured a remote docker host:

    export DOCKER_HOST=tcp://<remote_ip>:<port>
    script/build
    script/test

:warning: We use [BATS](https://github.com/sstephenson/bats) for the test harness.

Output from `script/test` resembles:


```
===> Clean up from previous test runs.
[RUN] docker_rm tftp
[RUN] docker_rm tftpd
[RUN] docker_rm downloads
[RUN] docker_rm fixtures

===> Create data container in which to download test files.
[RUN] docker create --name downloads -v /home/user alpine:3.3 true
d6c18494eb7deb05886cb9d6b90aa007c3e7ea449ab548077805f1640037bc6a
[RUN] docker run --rm --volumes-from downloads alpine:3.3 chown -R 1000:1000 /home/user

===> Create data container for fixtures.
[RUN] docker create --name fixtures hooktftp-fixtures true
6e51b79c0bf0f937779b51e0fc5b516cab61988a1e5aef59c587de0ae68d5b7c

===> Start hooktftp server.
[RUN] docker run -d -p 69:69/udp --volumes-from fixtures --name tftpd hooktftp-runtime
3b6dcd53daced561a6e669d819d3a547df400f3a5166122b4b71c3145e154f1f
Server is up at 172.17.0.2

===> Run BATS tests.
1..10
ok 1 hooktftp binary is owned by root:root
ok 2 hooktftp drops privileges
ok 3 downloads site/menu from fixtures
ok 4 downloads pxelinux.0
ok 5 does not download a non-existent-file
ok 6 downloads pxelinux.cfg/default
ok 7 downloads pxelinux.cfg/F1.msg
ok 8 hooktftp server log is meaningful
ok 9 HOOKTFTP_VERSION is a symlink at top-level
ok 10 HOOKTFTP_VERSION is a regular file in build direcctory
```


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
