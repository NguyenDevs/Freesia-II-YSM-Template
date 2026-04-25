#!/bin/bash
set -e

echo "============================================="
echo "  Freesia SUB_Lobby - Starting Up"
echo "============================================="

# ── 1. Override server.properties from environment variables ──────
PROPS_FILE="/server/server.properties"

apply_prop() {
    local key="$1"
    local value="$2"
    if [ -n "$value" ]; then
        if grep -q "^${key}=" "$PROPS_FILE"; then
            sed -i "s|^${key}=.*|${key}=${value}|" "$PROPS_FILE"
        else
            echo "${key}=${value}" >> "$PROPS_FILE"
        fi
        echo "  [PROPS] ${key} = ${value}"
    fi
}

echo "[1/3] Applying server.properties overrides..."
apply_prop "server-port"                  "${MC_PORT:-25566}"
apply_prop "server-ip"                    "${MC_BIND_IP:-0.0.0.0}"
apply_prop "max-players"                  "${MC_MAX_PLAYERS:-200}"
apply_prop "online-mode"                  "${MC_ONLINE_MODE:-false}"
apply_prop "motd"                         "${MC_MOTD:-A Minecraft Server}"

# ── 2. Fix permissions ───────────────────────────────────
echo "[2/3] Fixing file permissions..."
chown -R minecraft:minecraft /server/world /home/minecraft

# ── 3. Start server ──────────────────────────────────────
JVM_OPTS="${JVM_MAX_HEAP:--Xmx2G} ${JVM_MIN_HEAP:--Xms512M} ${JVM_EXTRA_OPTS:-}"

echo "[3/3] Starting Paper server as 'minecraft' user..."
echo "  JVM args: $JVM_OPTS"
echo "============================================="

exec gosu minecraft java $JVM_OPTS \
    -jar /server/paper-1.21.8-60.jar \
    nogui
