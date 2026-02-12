#!/bin/bash
# entrypoint.sh

# 1. Run configuration setup
/render.sh

# 2. Link persistent data if needed (TinyClaw logic uses $HOME/.tinyclaw by default)
# We override this in tinyclaw.sh or common.sh if we can, 
# but for now, let's symlink the volume data to the expected location.
mkdir -p /data/.tinyclaw/logs
mkdir -p /data/.tinyclaw/channels
mkdir -p /data/.tinyclaw/queue

# Link ~/.tinyclaw to our persistent volume
rm -rf "$HOME/.tinyclaw"
ln -s /data/.tinyclaw "$HOME/.tinyclaw"

# 3. Start tinyclaw
# We run it in the background or use the start command
./tinyclaw.sh start

# 4. Stay alive and tail logs
echo "TinyClaw is running. Tailing logs..."
tail -f /data/.tinyclaw/logs/*.log
