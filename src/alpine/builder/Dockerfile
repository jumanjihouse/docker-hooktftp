FROM gliderlabs/alpine

RUN apk update && \
    apk add bzr git go make gcc musl-dev

RUN adduser -D user
COPY . /home/user/

USER user
ENTRYPOINT ["/home/user/build.sh"]
