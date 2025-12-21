FROM maven:3.9.10-eclipse-temurin-8

SHELL ["/bin/bash", "-lc"]

# Install basic tools + Node.js 16 for the Vue2 frontend.
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    xz-utils \
  && rm -rf /var/lib/apt/lists/*

# Node 16 + npm 9 (supports lockfileVersion=3)
RUN curl -fsSL https://nodejs.org/dist/v16.20.2/node-v16.20.2-linux-x64.tar.xz \
  | tar -xJ -C /usr/local --strip-components=1 \
  && node -v \
  && npm -v \
  && npm install -g npm@9 \
  && npm -v

# The base image already provides an `ubuntu` user (uid/gid 1000). Use it to
# avoid UID/GID collisions while keeping mounted file permissions reasonable.
RUN mkdir -p /workspace \
  && chown -R ubuntu:ubuntu /workspace

USER ubuntu
WORKDIR /workspace
