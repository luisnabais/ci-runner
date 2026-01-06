FROM alpine:3.23.2

RUN apk add --no-cache \
    git \
    docker \
    docker-cli-buildx \
    openssh-client \
    ansible \
    bash \
    curl \
    rsync

RUN mkdir -p /root/.ssh && \
    chmod 700 /root/.ssh

ENTRYPOINT ["/bin/sh"]