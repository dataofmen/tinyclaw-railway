#!/bin/bash
# render.sh: Generates settings.json from environment variables

SETTINGS_FILE=${SETTINGS_FILE:-/data/.tinyclaw/settings.json}
WORKSPACE_PATH=${WORKSPACE_PATH:-/data/tinyclaw-workspace}

mkdir -p $(dirname "$SETTINGS_FILE")
mkdir -p "$WORKSPACE_PATH"

# Default values if not provided
DISCORD_ENABLED=${DISCORD_BOT_TOKEN:+true}
TELEGRAM_ENABLED=${TELEGRAM_BOT_TOKEN:+true}
WHATSAPP_ENABLED=${WHATSAPP_ENABLED:-false}

CHANNELS_ENABLED="[]"
[ "$DISCORD_ENABLED" = "true" ] && CHANNELS_ENABLED=$(echo "$CHANNELS_ENABLED" | jq '. + ["discord"]')
[ "$TELEGRAM_ENABLED" = "true" ] && CHANNELS_ENABLED=$(echo "$CHANNELS_ENABLED" | jq '. + ["telegram"]')
[ "$WHATSAPP_ENABLED" = "true" ] && CHANNELS_ENABLED=$(echo "$CHANNELS_ENABLED" | jq '. + ["whatsapp"]')

# Provider configuration
DEFAULT_PROVIDER=${DEFAULT_PROVIDER:-anthropic}
DEFAULT_MODEL=${DEFAULT_MODEL:-sonnet}
# Default to Ollama Cloud URL; user can override to http://host.docker.internal:11434 for local
OLLAMA_BASE_URL=${OLLAMA_BASE_URL:-https://ollama.com}

# Construct JSON
jq -n \
  --argjson enabled "$CHANNELS_ENABLED" \
  --arg discord_token "$DISCORD_BOT_TOKEN" \
  --arg telegram_token "$TELEGRAM_BOT_TOKEN" \
  --arg workspace "$WORKSPACE_PATH" \
  --arg provider "$DEFAULT_PROVIDER" \
  --arg model "$DEFAULT_MODEL" \
  --arg ollama_url "$OLLAMA_BASE_URL" \
  --arg ollama_key "$OLLAMA_API_KEY" \
  '{
    channels: {
      enabled: $enabled,
      discord: { bot_token: $discord_token },
      telegram: { bot_token: $telegram_token },
      whatsapp: {}
    },
    workspace: {
      path: $workspace,
      name: "tinyclaw-workspace"
    },
    models: {
      provider: $provider,
      anthropic: { model: $model },
      openai: { model: $model }
    },
    ollama: {
      base_url: $ollama_url,
      api_key: $ollama_key
    },
    monitoring: {
      heartbeat_interval: 3600
    }
  }' > "$SETTINGS_FILE"

echo "Generated settings.json at $SETTINGS_FILE"
