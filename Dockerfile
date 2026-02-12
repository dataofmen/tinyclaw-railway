FROM node:20-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    tmux \
    bash \
    jq \
    curl \
    git \
    procps \
    && rm -rf /var/lib/apt/lists/*

# Install global AI CLIs
RUN npm install -g @anthropic-ai/claude-code

WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install

# Copy the rest of the application
COPY . .

# Build TypeScript
RUN npm run build

# Create directory for persistent data (Railway Volume)
RUN mkdir -p /data/.tinyclaw

# Make scripts executable
RUN chmod +x ./tinyclaw.sh ./scripts/*.sh ./lib/*.sh

# Environmental variable defaults
ENV WORKSPACE_PATH=/data/tinyclaw-workspace
ENV SETTINGS_FILE=/data/.tinyclaw/settings.json
ENV TINYCLAW_HOME=/app

# Expose port (not strictly needed for bots but good for Railway health checks if added later)
EXPOSE 3000

# Copy and setup entrypoint
COPY entrypoint.sh /entrypoint.sh
COPY render.sh /render.sh
RUN chmod +x /entrypoint.sh /render.sh

ENTRYPOINT ["/entrypoint.sh"]
