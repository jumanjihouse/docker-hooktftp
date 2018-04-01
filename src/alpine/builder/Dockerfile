FROM alpine:3.7

RUN apk add --no-cache \
      busybox-extras \
      bzr \
      git \
      make \
      gcc \
      musl-dev

RUN apk add --no-cache -X http://dl-4.alpinelinux.org/alpine/edge/community \
      'go>=1.10'

RUN adduser -D user
COPY . /home/user/

USER user
ENTRYPOINT ["/home/user/build.sh"]
