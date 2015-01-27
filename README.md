hooktftp in a container!
========================

Project URL: [https://github.com/jumanjihouse/hooktftp-runtime](https://github.com/jumanjihouse/hooktftp-runtime)


Overview
--------

This source is used to build an image for
[hooktftp](https://github.com/epeli/hooktftp).

The primary artifact is a docker image with the `hooktftp` static binary
and a default, minimal configuration.

The goal is to provide a compromise between a single, monolithic
tftpd image that contains *all the things* and a flexible tftpd
image that contains *just enough* to combine with custom-built
data containers or volumes an organization needs to bootstrap
their infrastructure.


License
-------

See [`LICENSE`](LICENSE) in this repo.
