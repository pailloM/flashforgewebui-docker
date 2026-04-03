## FlashForgeWebUI — Docker usage

Quick instructions to run the FlashForgeWebUI Docker image built from this repository.

Prereqs:
- Docker (Engine) or Docker Desktop
- (Optional) Docker Compose
  
  
### Run with docker run

Run with default options (bind port 3000, persistent data at /path/on/host/data):
  
docker run -d \
  --name flashforge-webui \
  -p 3000:3000 \
  -v /path/on/host/data:/data \
  ghcr.io/pailloM/flashforge-webui-docker:latest
  
Common runtime options:
- Set webui port and password (overrides defaults):
  docker run -d --name flashforge-webui -p 3000:3000 -v /path/on/host/data:/data ghcr.io/<owner>/flashforge-webui-docker:latest --webui-port=3000 --webui-password=yourpassword
- Run interactively for debugging:
  docker run --rm -it -p 3000:3000 -v /path/on/host/data:/data ghcr.io/<owner>/flashforge-webui:latest /bin/sh
  
### Run with Docker Compose
  
docker-compose.yml (simple example):
  
```yaml
version: "3.8"
services:
  flashforge-webui:
    image: ghcr.io/pailloM/flashforge-webui-docker:latest
    container_name: flashforge-webui
    ports:
      - "3000:3000"
    volumes:
      - ./data:/data
    restart: unless-stopped
    command: ["--webui-port=3000","--webui-password=changeme"]
```
  
Start:
docker compose up -d
  
Change the image tag to a specific release (e.g., :v1.2.3) to pin versions.
  
### Data & configuration
- Persistent data directory: /data in container (map to host with -v or volumes in Compose).
- Configure runtime options by adding command-line flags to docker run or the Compose `command` array.
  
### Tips
- To view container logs: docker logs -f flashforge-webui
- To shell into container: docker exec -it flashforge-webui /bin/sh
- If using a registry that requires auth, log in first: docker login ghcr.io (or replace image host with your registry)
  
That's it — adjust ports, volumes, and flags as needed for your environment.