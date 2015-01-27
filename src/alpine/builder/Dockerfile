FROM gliderlabs/alpine

RUN apk update && \
    apk add bzr git go

RUN adduser -D user
COPY build.sh /home/user/

USER user
ENTRYPOINT ["/home/user/build.sh"]
