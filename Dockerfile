FROM alpine:3.19

ENV LANG=C.UTF-8 \
    NODE_ENV=production \
    DATA_DIR=/data \
    PORT=3000 \
    PASSWORD=changeme

RUN apk update && apk upgrade && \
    apk add --no-cache \
      libc6-compat \
      ca-certificates \
      curl \
      bash \
      tar \
      xz \
      su-exec \
      tzdata

ARG BIN_NAME=flashforge-webui-linux-x64.bin
ARG REPO=Parallel-7/FlashForgeWebUI

WORKDIR /opt/flashforge

# Download latest release binary via GitHub releases/latest redirect
RUN set -eux; \
    curl -fSL "https://github.com/${REPO}/releases/latest/download/${BIN_NAME}" -o /opt/flashforge/${BIN_NAME} || { echo "Failed to download latest binary"; exit 1; }; \
    chmod +x /opt/flashforge/${BIN_NAME}

RUN mkdir -p ${DATA_DIR} && chown -R root:root /opt/flashforge

RUN ls -als /opt/flashforge

VOLUME ["/data"]

EXPOSE ${PORT}

ENTRYPOINT ["/opt/flashforge/flashforge-webui-linux-x64.bin"]
CMD ["--webui-port=${PORT}","--webui-password=${PASSWORD}"]
