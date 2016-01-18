FROM alpine:3.3

# CA certs are important if you add a hook for https.
RUN apk add --no-cache \
      ca-certificates \
      file

# Add the static binary.
COPY hooktftp /usr/bin/

# Allow admin to tie image back to an automated build.
COPY wercker-build-url /root/

# Add a trivial config that can be overridden at runtime.
COPY hooktftp.yml /etc/hooktftp/hooktftp.yml
VOLUME /etc/hooktftp

# Publish the typical syslinux and pxelinux files at tftp root.
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

# Add safe defaults that can be overriden easily.
COPY pxelinux.cfg /tftpboot/pxelinux.cfg/

# Do not track further change to /tftpboot.
VOLUME /tftpboot

# Run hooktftp by default at runtime.
RUN adduser -D hooktftp
ENTRYPOINT ["/usr/bin/hooktftp"]
CMD ["-v", "/etc/hooktftp/hooktftp.yml"]
