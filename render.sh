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

# Construct JSON
jq -n \
  --argjson enabled "$CHANNELS_ENABLED" \
  --arg discord_token "$DISCORD_BOT_TOKEN" \
  --arg telegram_token "$TELEGRAM_BOT_TOKEN" \
  --arg workspace "$WORKSPACE_PATH" \
  --arg model "${DEFAULT_MODEL:-sonnet}" \
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
      provider: "anthropic",
      anthropic: { model: $model }
    },
    monitoring: {
      heartbeat_interval: 3600
    }
  }' > "$SETTINGS_FILE"

echo "Generated settings.json at $SETTINGS_FILE"
