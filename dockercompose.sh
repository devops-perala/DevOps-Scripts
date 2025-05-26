#!/bin/bash

# Install Docker Compose v2 (as a Docker plugin)
DOCKER_COMPOSE_VERSION="v2.24.6"  # Use latest stable version

# Create plugin directory
mkdir -p ~/.docker/cli-plugins/

# Download Docker Compose binary
curl -SL https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-linux-x86_64 \
  -o ~/.docker/cli-plugins/docker-compose

# Make it executable
chmod +x ~/.docker/cli-plugins/docker-compose

# Verify installation
docker compose version
