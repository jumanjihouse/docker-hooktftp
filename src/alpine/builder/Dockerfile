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
RUN /home/user/build

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

# Enable to add entries to /etc/hosts via
#   docker run --add-host
# or via the docker-compose extra_hosts option.
COPY nsswitch.conf /etc/nsswitch.conf

# Run hooktftp by default at runtime.
COPY passwd /etc/passwd
ENTRYPOINT ["/usr/bin/hooktftp"]
CMD ["-v", "/etc/hooktftp/hooktftp.yml"]

ARG CIRCLE_BUILD_URL
ARG BUILD_DATE
ARG HOOKTFTP_VERSION
ARG VCS_REF
ARG TAG

LABEL \
    io.github.jumanjiman.ci-build-url="${CIRCLE_BUILD_URL}" \
    io.github.jumanjiman.upstream-url="https://github.com/tftp-go-team/hooktftp/commit/${HOOKTFTP_VERSION}" \
    org.label-schema.name="jumanjiman/hooktftp" \
    org.label-schema.description="Hook based tftp server written in Go (golang)" \
    org.label-schema.url="https://github.com/jumanjihouse/docker-hooktftp" \
    org.label-schema.vcs-url="https://github.com/jumanjihouse/docker-hooktftp.git" \
    org.label-schema.docker.dockerfile="/src/alpine/builder/Dockerfile" \
    org.label-schema.vcs-type="Git" \
    org.label-schema.license="https://github.com/jumanjihouse/docker-hooktftp/blob/master/LICENSE" \
    org.label-schema.build-date="${BUILD_DATE}" \
    org.label-schema.vcs-ref="${VCS_REF}" \
    org.label-schema.version="${TAG}"
