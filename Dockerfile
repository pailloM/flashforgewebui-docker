# Multi-stage build: clone, build, then produce runtime image
# Save as Dockerfile

ARG REPO_URL="https://github.com/Parallel-7/FlashForgeWebUI.git"
ARG REPO_REF="HEAD"   # change to a tag/branch/commit if you want to pin

# ---- builder ----
FROM node:20-alpine AS builder

ARG REPO_URL
ARG REPO_REF

# keep base packages updated and install build deps
RUN apk update && apk upgrade && rm -rf /var/cache/apk/* \
  && apk add --no-cache git build-base python3

WORKDIR /usr/src/app

# clone the repo (shallow) and check out the requested ref
RUN set -eux; \
  git clone --depth 1 --branch "${REPO_REF}" "${REPO_URL}" . || { \
    # If branch not found, fall back to shallow clone of default branch
    rm -rf .git && git clone --depth 1 "${REPO_URL}" .; \
  }

# install dependencies and build
RUN npm install
RUN npm run build

# ---- runtime ----
FROM node:20-alpine AS runtime

ENV LANG=C.UTF-8 \
    NODE_ENV=production \
    DATA_DIR=/data \
    PORT=3000 \
    PASSWORD=changeme

# keep base updated
RUN apk update && apk upgrade && rm -rf /var/cache/apk/*

WORKDIR /opt/flashforge

# copy built app and package files from builder
COPY --from=builder /usr/src/app /opt/flashforge

# ensure only production deps are installed
RUN if [ -f package-lock.json ]; then npm ci --omit=dev; else npm prune --production || true; fi

# create data dir and use non-root user
RUN addgroup -S app && adduser -S app -G app \
  && mkdir -p ${DATA_DIR} && chown -R app:app /opt/flashforge ${DATA_DIR}

USER app

VOLUME ["/data"]
EXPOSE ${PORT}

# Default: start server. To pass flags (e.g., --last-used) append them after the image name.
CMD ["sh", "-c", "npm start -- --webui-port=${PORT} --webui-password=${PASSWORD}"]
