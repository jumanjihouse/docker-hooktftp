FROM alpine:3.3

RUN apk add --no-cache \
      bzr \
      git \
      go \
      make \
      gcc \
      musl-dev

RUN adduser -D user
COPY . /home/user/

USER user
ENTRYPOINT ["/home/user/build.sh"]
