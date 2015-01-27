FROM gliderlabs/alpine

# Install dependencies.
RUN apk update && apk add tftp-hpa

# Add unprivileged user.
RUN adduser -D user
USER user
VOLUME /home/user
WORKDIR /home/user
ENTRYPOINT ["/usr/bin/tftp"]
