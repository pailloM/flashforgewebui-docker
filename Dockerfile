FROM debian:bookworm-slim

# metadata / defaults
ARG REPO=Parallel-7/FlashForgeWebUI
ARG BIN_NAME=flashforge-webui-linux-x64.bin
ENV DATA_DIR=/data \
    PORT=3000 \
    LANG=C.UTF-8 \
    NODE_ENV=production \
    PASSWORD=changeme

# update base and install runtime deps
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends curl ca-certificates tini && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt/flashforge

# download latest release binary from GitHub releases
# (uses releases/latest redirect)
ARG REPO
ARG BIN_NAME
RUN set -eux; \
    curl -fSL "https://github.com/${REPO}/releases/latest/download/${BIN_NAME}" -o /opt/flashforge/${BIN_NAME} || { echo "Failed to download ${BIN_NAME}"; exit 1; }; \
    chmod +x /opt/flashforge/${BIN_NAME}

# create data dir and non-root user
#RUN useradd -m -d /home/ffuser -s /bin/false ffuser && \
#    mkdir -p ${DATA_DIR} && chown -R ffuser:ffuser /opt/flashforge ${DATA_DIR}

VOLUME ["/data"]
EXPOSE ${PORT}

ENTRYPOINT ["/usr/bin/tini", "--", "/opt/flashforge/flashforge-webui-linux-x64.bin"]
CMD ["--last-used","--webui-port=3000","--webui-password=changeme"]

HEALTHCHECK --interval=1m --timeout=5s --start-period=30s --retries=3 \
  CMD curl -sfS "http://127.0.0.1:${PORT}/" >/dev/null || exit 1