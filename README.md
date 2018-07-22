hooktftp in a container!
========================

This source is used to build an image for
[hooktftp](https://github.com/tftp-go-team/hooktftp).

Project URL: [https://github.com/jumanjihouse/docker-hooktftp](https://github.com/jumanjihouse/docker-hooktftp)<br/>
Registry: [https://registry.hub.docker.com/u/jumanjiman/hooktftp/](https://registry.hub.docker.com/u/jumanjiman/hooktftp/)

[![](https://images.microbadger.com/badges/image/jumanjiman/hooktftp.svg)](https://microbadger.com/images/jumanjiman/hooktftp "View on microbadger.com")&nbsp;
[![](https://images.microbadger.com/badges/version/jumanjiman/hooktftp.svg)](https://microbadger.com/images/jumanjiman/hooktftp "View on microbadger.com")&nbsp;
[![Docker Registry](https://img.shields.io/docker/pulls/jumanjiman/hooktftp.svg)](https://registry.hub.docker.com/u/jumanjiman/hooktftp 'View on docker hub')&nbsp;
[![Circle CI](https://circleci.com/gh/jumanjihouse/docker-hooktftp.png?style=svg&circle-token=5bf142a4f054bf78f7abd3f9f2ab553d054de414)](https://circleci.com/gh/jumanjihouse/docker-hooktftp/tree/master 'View CI builds')

The primary artifact is a docker image with the `hooktftp` binary
and a default, minimal configuration.
<br/>The runtime image contains **only**:

* a static binary,
* a default config file,
* CA certificates, and
* `/etc/passwd` to provide an unprivileged user.

The container runs as an unprivileged user via the technique described in
[this Medium post](https://medium.com/@lizrice/non-privileged-containers-based-on-the-scratch-image-a80105d6d341).

The goal is to provide a compromise between a single, monolithic
tftpd image that contains *all the things* and a flexible tftpd
image that contains *just enough* to combine with custom-built
data containers or volumes an organization needs to bootstrap
their infrastructure.

**Table of Contents**

- [Build integrity and docker tags](#build-integrity-and-docker-tags)
- [How-to](#how-to)
    - [Fetch an already-built image](#fetch-an-already-built-image)
    - [List files in the image](#list-files-in-the-image)
    - [Load NetFilter modules](#load-netfilter-modules)
    - [Configure and run](#configure-and-run)
    - [Use systemd for automatic startup](#use-systemd-for-automatic-startup)
    - [Build](#build)
    - [Test](#test)
    - [Publish to a private registry](#publish-to-a-private-registry)
- [Contribute](#contribute)
- [License](#license)


Build integrity and docker tags
-------------------------------

An unattended test harness runs the build script and acceptance tests.
If all tests pass on master branch in the unattended test harness,
circleci pushes the built image to the Docker hub.

The CI scripts apply two tags before pushing to docker hub:

* `jumanjiman/hooktftp:latest`: latest successful build on master branch
* `jumanjiman/hooktftp:<date>T<time>-<git-hash>`: a particular build on master branch

Therefore you can `docker pull` a specific tag if you don't want *latest*.


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
[inside the image](src/alpine/builder/hooktftp.yml) or provide
your own at runtime.

The published image contains *just enough* files to provide
a base tftpd to PXE-boot your hosts to a simple menu.
The [simple menu](src/alpine/builder/pxelinux.cfg/F1.msg) and
[pxelinux.cfg/default](src/alpine/builder/pxelinux.cfg/default)
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
| hooktftp-runtime |   8 MB | run hooktftp as a service      |
| tftp             |   6 MB | test the runtime container     |

On a docker host, run:

    ci/build


### Test

:warning: We use [BATS](https://github.com/sstephenson/bats) for the test harness.

On a docker host, run:

    ci/test

You can also test via the docker remote API if you have configured a remote docker host:

    export DOCKER_HOST=tcp://<remote_ip>:<port>
    ci/build
    ci/test

Output from `ci/test` resembles:

    ===> Run file checks.
    [forbid-binary] Forbid binaries..........................................(no files to check)Skipped
    [git-check] Check for conflict markers and core.whitespace errors............................Passed
    [git-dirty] Check if the git tree is dirty...................................................Passed
    [shellcheck] Test shell scripts with shellcheck..............................................Passed
    [yamllint] yamllint..........................................................................Passed
    [check-added-large-files] Check for added large files........................................Passed
    [check-case-conflict] Check for case conflicts...............................................Passed
    [check-executables-have-shebangs] Check that executables have shebangs.......................Passed
    [check-json] Check JSON..................................................(no files to check)Skipped
    [check-merge-conflict] Check for merge conflicts.............................................Passed
    [check-xml] Check Xml....................................................(no files to check)Skipped
    [check-yaml] Check Yaml......................................................................Passed
    [detect-private-key] Detect Private Key......................................................Passed
    [forbid-crlf] CRLF end-lines checker.........................................................Passed
    [forbid-tabs] No-tabs checker................................................................Passed

    ===> Clean up from previous test runs.
    [RUN] docker_rm tftp
    [RUN] docker_rm tftpd
    [RUN] docker_rm downloads
    [RUN] docker_rm fixtures

    ===> Create data container in which to download test files.
    [RUN] docker create --name downloads -v /home/user ${BASE_IMAGE} true
    19d787a81fa8cc3d68fdd97f0d7fa85d2d3f95fadcd144e52f47aafda74fb763
    [RUN] docker run --rm --volumes-from downloads ${BASE_IMAGE} chown -R 1000:1000 /home/user

    ===> Create data container for fixtures.
    [RUN] docker create --name fixtures hooktftp-fixtures true
    35887d1b1761350b9dda5dac398822d91d9e7375cd29ef2b88feb3e7b97d7d41

    ===> Start hooktftp server.
    [RUN] docker run -d -p 69:69/udp --volumes-from fixtures --name tftpd hooktftp-runtime
    28cd162ee8edbe314354ec09d5bbd65bb40350d977d41d9544f6d1482a98f144
    Server is up at 172.17.0.3

    ===> Run BATS tests.
    1..11
    ok 1 hooktftp drops privileges
    ok 2 downloads site/menu from fixtures
    ok 3 downloads pxelinux.0
    ok 4 does not download a non-existent-file
    ok 5 downloads pxelinux.cfg/default
    ok 6 downloads pxelinux.cfg/F1.msg
    ok 7 hooktftp server log is meaningful
    ok 8 file command is available
    ok 9 scanelf command is available
    ok 10 hooktftp binary is stripped
    ok 11 hooktftp binary is statically compiled
    ci/test OK


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
