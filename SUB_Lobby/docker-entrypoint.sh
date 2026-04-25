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
            sed "s|^${key}=.*|${key}=${value}|" "$PROPS_FILE" > "$PROPS_FILE.tmp" && cat "$PROPS_FILE.tmp" > "$PROPS_FILE" && rm "$PROPS_FILE.tmp"
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
apply_prop "motd"                         "${MC_MOTD:-Freesia Sub Lobby}"
apply_prop "difficulty"                   "${MC_DIFFICULTY:-peaceful}"
apply_prop "gamemode"                     "${MC_GAMEMODE:-adventure}"
apply_prop "pvp"                          "${MC_PVP:-true}"
apply_prop "spawn-protection"             "${MC_SPAWN_PROTECTION:-1}"
apply_prop "view-distance"                "${MC_VIEW_DISTANCE:-10}"
apply_prop "simulation-distance"          "${MC_SIMULATION_DISTANCE:-10}"
apply_prop "allow-nether"                 "${MC_ALLOW_NETHER:-false}"
apply_prop "generate-structures"          "${MC_GENERATE_STRUCTURES:-false}"
apply_prop "max-tick-time"                "${MC_MAX_TICK_TIME:-60000}"
apply_prop "network-compression-threshold" "${MC_NETWORK_COMPRESSION_THRESHOLD:-256}"

# ── 2. Fix permissions (Selective to avoid hanging on large volumes) ──
echo "[2/3] Fixing file permissions..."
chown minecraft:minecraft /server
chown -R minecraft:minecraft /server/world /server/logs /server/plugins /home/minecraft 2>/dev/null || true

# ── 3. Start server ──────────────────────────────────────
JVM_OPTS="${JVM_MAX_HEAP:--Xmx2G} ${JVM_MIN_HEAP:--Xms512M} ${JVM_EXTRA_OPTS:-}"

echo "[3/3] Starting Paper server as 'minecraft' user..."
echo "  JVM args: $JVM_OPTS"
echo "============================================="

exec gosu minecraft java $JVM_OPTS \
    -jar /server/paper-1.21.8-60.jar \
    nogui
