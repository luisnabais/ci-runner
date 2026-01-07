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
    echo '  echo "Checking Docker Buildx setup..."' >> /entrypoint.sh && \
    echo '  ' >> /entrypoint.sh && \
    echo '  # Check if builder exists and is running' >> /entrypoint.sh && \
    echo '  if ! docker buildx inspect multiarch-builder >/dev/null 2>&1; then' >> /entrypoint.sh && \
    echo '    echo "Creating multiarch-builder..."' >> /entrypoint.sh && \
    echo '    docker buildx create \' >> /entrypoint.sh && \
    echo '      --name multiarch-builder \' >> /entrypoint.sh && \
    echo '      --driver docker-container \' >> /entrypoint.sh && \
    echo '      --driver-opt image=moby/buildkit:latest \' >> /entrypoint.sh && \
    echo '      --driver-opt network=host \' >> /entrypoint.sh && \
    echo '      --bootstrap \' >> /entrypoint.sh && \
    echo '      --use' >> /entrypoint.sh && \
    echo '  else' >> /entrypoint.sh && \
    echo '    echo "Builder exists, ensuring it is active..."' >> /entrypoint.sh && \
    echo '    docker buildx use multiarch-builder' >> /entrypoint.sh && \
    echo '    # Check if builder container is running, restart if needed' >> /entrypoint.sh && \
    echo '    if ! docker buildx inspect multiarch-builder --bootstrap >/dev/null 2>&1; then' >> /entrypoint.sh && \
    echo '      echo "Builder not running, recreating..."' >> /entrypoint.sh && \
    echo '      docker buildx rm multiarch-builder 2>/dev/null || true' >> /entrypoint.sh && \
    echo '      docker buildx create \' >> /entrypoint.sh && \
    echo '        --name multiarch-builder \' >> /entrypoint.sh && \
    echo '        --driver docker-container \' >> /entrypoint.sh && \
    echo '        --driver-opt image=moby/buildkit:latest \' >> /entrypoint.sh && \
    echo '        --driver-opt network=host \' >> /entrypoint.sh && \
    echo '        --bootstrap \' >> /entrypoint.sh && \
    echo '        --use' >> /entrypoint.sh && \
    echo '    fi' >> /entrypoint.sh && \
    echo '  fi' >> /entrypoint.sh && \
    echo '  ' >> /entrypoint.sh && \
    echo '  echo "Current buildx configuration:"' >> /entrypoint.sh && \
    echo '  docker buildx ls' >> /entrypoint.sh && \
    echo 'fi' >> /entrypoint.sh && \
    echo '' >> /entrypoint.sh && \
    echo '# Execute the command passed to the container' >> /entrypoint.sh && \
    echo 'exec "$@"' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/sh"]