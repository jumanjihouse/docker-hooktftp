ARG BASE_IMAGE
FROM ${BASE_IMAGE} as builder

RUN apk add --no-cache \
      busybox-extras \
      bzr \
      ca-certificates \
      git \
      make \
      gcc \
      patch \
      musl-dev

RUN apk add --no-cache -X http://dl-4.alpinelinux.org/alpine/edge/community \
      'go>=1.10'

# We only need one subtree of files from syslinux, and
# we don't need its dependencies, so...
#
# Install the package and its dependencies as a virtual set "sl_plus_deps",
# copy the desired files, then purge the virtual set.
#
# This trick keeps the image as small as possible.
#
# NOTE: If you bump the syslinux version here,
#       please also update the README.md.
RUN apk add --no-cache --virtual sl_plus_deps "syslinux>=6.03-r0" && \
    cp -r /usr/share/syslinux /tftpboot && \
    find /tftpboot -type f -exec chmod 0444 {} + && \
    apk del --no-cache sl_plus_deps

RUN adduser -D user
COPY . /home/user/

ARG HOOKTFTP_VERSION
ENV HOOKTFTP_VERSION="${HOOKTFTP_VERSION}"

USER user
RUN /home/user/build.sh

################################################################################
# Runtime image.
################################################################################
FROM scratch

# CA certs are important if you add a hook for https.
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt

# Add the static binary.
COPY --from=builder /tmp/hooktftp /usr/bin/

# Add a trivial config that can be overridden at runtime.
COPY hooktftp.yml /etc/hooktftp/hooktftp.yml
VOLUME /etc/hooktftp

# Publish the typical syslinux and pxelinux files at tftp root.
COPY --from=builder /tftpboot /tftpboot

# Add safe defaults that can be overriden easily.
COPY pxelinux.cfg /tftpboot/pxelinux.cfg/

# Do not track further change to /tftpboot.
VOLUME /tftpboot

# Run hooktftp by default at runtime.
COPY passwd /etc/passwd
ENTRYPOINT ["/usr/bin/hooktftp"]
CMD ["-v", "/etc/hooktftp/hooktftp.yml"]
