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
The runtime image is quite small (roughly 14 MB) since it is based on
[Alpine Linux](https://www.alpinelinux.org/).
I may support other userspaces in the future.

The goal is to provide a compromise between a single, monolithic
tftpd image that contains *all the things* and a flexible tftpd
image that contains *just enough* to combine with custom-built
data containers or volumes an organization needs to bootstrap
their infrastructure.


How-to
------

### Fetch an already-built image

The runtime image is published as `jumanjiman/hooktftp`.

    docker pull jumanjiman/hooktftp


### Configure and run

The container reads the config file `/etc/hooktftp/hooktftp.yml`
inside the container. You can use the default config provided
[inside the image](src/alpine/runtime/hooktftp.yml) or provide
your own at runtime.

Run a container with default config and your data:

    docker run -d -p 69:69/udp \
      -v /path/to/your/files:/tftpboot:ro \
      jumanjiman/hooktftp

Run a container with your own config and your own data:

    docker run -d -p 69:69/udp \
      -v /path/to/your/files:/tftpboot:ro \
      -v /path/to/your/config/dir:/etc/hooktftp:ro \
      jumanjiman/hooktftp


### Build

The build script(s) produce multiple artifacts:

| Image Tag        | Size   | Purpose                        |
| :--------------- | -----: | :----------------------------- |
| hooktftp-builder | 400 MB | compile hooktftp static binary |
| hooktftp-runtime |  14 MB | run hooktftp as a service      |
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


License
-------

See [`LICENSE`](LICENSE) in this repo.
