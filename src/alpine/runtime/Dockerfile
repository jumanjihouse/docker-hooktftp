FROM gliderlabs/alpine

# CA certs are important if you add a hook for https.
RUN apk update && \
    apk add ca-certificates

# Add the static binary.
COPY hooktftp /usr/bin/

# Allow admin to tie image back to an automated build.
COPY wercker-build-url /root/

# Add a trivial config that can be overridden at runtime.
COPY hooktftp.yml /etc/hooktftp/hooktftp.yml
VOLUME /etc/hooktftp

# Create an empty download dir that can be overridden at runtime.
RUN mkdir /tftpboot
VOLUME /tftpboot

# Run hooktftp by default at runtime.
RUN adduser -D hooktftp
ENTRYPOINT ["/usr/bin/hooktftp", "/etc/hooktftp/hooktftp.yml"]
