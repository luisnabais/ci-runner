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

# Create entrypoint script to setup buildx
RUN echo '#!/bin/bash' > /entrypoint.sh && \
    echo 'set -e' >> /entrypoint.sh && \
    echo '' >> /entrypoint.sh && \
    echo '# Setup Docker Buildx with multiarch support' >> /entrypoint.sh && \
    echo 'if [ -S /var/run/docker.sock ]; then' >> /entrypoint.sh && \
    echo '  echo "Setting up buildx builder..."' >> /entrypoint.sh && \
    echo '  docker buildx create --use --name multiarch-builder --driver docker-container --driver-opt image=moby/buildkit:latest --driver-opt network=host 2>/dev/null || docker buildx use multiarch-builder 2>/dev/null || true' >> /entrypoint.sh && \
    echo '  echo "Builder setup complete"' >> /entrypoint.sh && \
    echo '  docker buildx ls' >> /entrypoint.sh && \
    echo 'fi' >> /entrypoint.sh && \
    echo '' >> /entrypoint.sh && \
    echo '# Execute the command passed to the container' >> /entrypoint.sh && \
    echo 'exec "$@"' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/sh"]