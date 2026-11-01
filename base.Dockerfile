# Shared toolbox image for the estate labs.
# Not used by the first slice yet: `tools` currently pulls nicolaka/netshoot.
# Build and publish this to GHCR when the image needs to be pinned and offline-friendly.
FROM alpine:3.20

RUN apk add --no-cache \
    bash \
    curl \
    bind-tools \
    tcpdump \
    iproute2 \
    openssl \
    postgresql-client \
    vim \
    less

CMD ["sleep", "infinity"]
