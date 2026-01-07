FROM alpine:3.23.2

RUN apk add --no-cache \
    git \
    docker \
    docker-cli-buildx \
    openssh-client \
    ansible \
    bash \
    curl \
    rsync \
    qemu \
    qemu-aarch64 \
    qemu-x86_64

RUN mkdir -p /root/.ssh && \
    chmod 700 /root/.ssh