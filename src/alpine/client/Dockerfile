FROM gliderlabs/alpine

# Install dependencies.
RUN apk update && apk add tftp-hpa

# Add unprivileged user with UID to match data container permissions in test harness.
RUN adduser -D -u 1000 user
USER user
VOLUME /home/user
WORKDIR /home/user
ENTRYPOINT ["/usr/bin/tftp"]
