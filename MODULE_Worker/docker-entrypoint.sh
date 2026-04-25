#!/bin/bash
set -e

# ─────────────────────────────────────────────────────────
# docker-entrypoint.sh — Freesia Worker Node Startup Script
# ─────────────────────────────────────────────────────────

echo "============================================="
echo "  Freesia MODULE_Worker - Starting Up"
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

echo "[1/4] Applying server.properties overrides..."
apply_prop "server-port"                  "${MC_PORT:-19199}"
apply_prop "server-ip"                    "${MC_BIND_IP:-0.0.0.0}"
apply_prop "max-players"                  "${MC_MAX_PLAYERS:-2000}"
apply_prop "online-mode"                  "${MC_ONLINE_MODE:-true}"
apply_prop "motd"                         "${MC_MOTD:-Freesia Worker Node}"
apply_prop "difficulty"                   "${MC_DIFFICULTY:-peaceful}"
apply_prop "gamemode"                     "${MC_GAMEMODE:-survival}"
apply_prop "pvp"                          "${MC_PVP:-false}"
apply_prop "allow-nether"                 "${MC_ALLOW_NETHER:-false}"
apply_prop "generate-structures"          "${MC_GENERATE_STRUCTURES:-false}"
apply_prop "view-distance"               "${MC_VIEW_DISTANCE:-1}"
apply_prop "simulation-distance"          "${MC_SIMULATION_DISTANCE:-1}"
apply_prop "network-compression-threshold" "${MC_COMPRESSION_THRESHOLD:-256}"
apply_prop "prevent-proxy-connections"    "${MC_PREVENT_PROXY:-false}"
apply_prop "enforce-secure-profile"       "${MC_ENFORCE_SECURE_PROFILE:-true}"
apply_prop "spawn-animals"                "${MC_SPAWN_ANIMALS:-false}"
apply_prop "spawn-monsters"               "${MC_SPAWN_MONSTERS:-false}"
apply_prop "spawn-npcs"                   "${MC_SPAWN_NPCS:-true}"
apply_prop "max-tick-time"                "${MC_MAX_TICK_TIME:-60000}"
apply_prop "log-ips"                      "${MC_LOG_IPS:-false}"
apply_prop "level-type"                   "${MC_LEVEL_TYPE:-flat}"
apply_prop "sync-chunk-writes"            "${MC_SYNC_CHUNK_WRITES:-false}"
apply_prop "entity-broadcast-range-percentage" "${MC_ENTITY_BROADCAST:-10}"

# ── 2. Override freesia_config.toml ───────────────────────
FREESIA_CFG="/server/config/freesia_config.toml"
echo "[2/4] Applying freesia_config.toml overrides..."

# If file doesn't exist, we skip (it will be created by the server later)
if [ -f "$FREESIA_CFG" ]; then
    if [ -n "$FREESIA_MASTER_IP" ]; then
        sed -i "s|^[[:space:]]*worker_master_ip = \".*\"|	worker_master_ip = \"${FREESIA_MASTER_IP}\"|" "$FREESIA_CFG"
        echo "  [CFG] worker_master_ip = ${FREESIA_MASTER_IP}"
    fi

    if [ -n "$FREESIA_MASTER_PORT" ]; then
        sed -i "s|^[[:space:]]*worker_master_port = .*|	worker_master_port = ${FREESIA_MASTER_PORT}|" "$FREESIA_CFG"
        echo "  [CFG] worker_master_port = ${FREESIA_MASTER_PORT}"
    fi

    if [ -n "$FREESIA_RECONNECT_INTERVAL" ]; then
        sed -i "s|^[[:space:]]*controller_reconnect_interval = .*|	controller_reconnect_interval = ${FREESIA_RECONNECT_INTERVAL}|" "$FREESIA_CFG"
        echo "  [CFG] controller_reconnect_interval = ${FREESIA_RECONNECT_INTERVAL}"
    fi

    if [ -n "$FREESIA_CACHE_INVALIDATE" ]; then
        sed -i "s|^[[:space:]]*player_data_cache_invalidate_interval_seconds = .*|	player_data_cache_invalidate_interval_seconds = ${FREESIA_CACHE_INVALIDATE}|" "$FREESIA_CFG"
        echo "  [CFG] player_data_cache_invalidate_interval_seconds = ${FREESIA_CACHE_INVALIDATE}"
    fi

    # TLS / Security settings
    if [ -n "$FREESIA_TLS_ENABLED" ]; then
        sed -i "s|^[[:space:]]*enable_tls = .*|	enable_tls = ${FREESIA_TLS_ENABLED}|" "$FREESIA_CFG"
        echo "  [CFG] enable_tls = ${FREESIA_TLS_ENABLED}"
    fi

    if [ -n "$FREESIA_TRUST_ALL" ]; then
        sed -i "s|^[[:space:]]*trust_all = .*|	trust_all = ${FREESIA_TRUST_ALL}|" "$FREESIA_CFG"
        echo "  [CFG] trust_all = ${FREESIA_TRUST_ALL}"
    fi
fi

# ── 3. Inject certificates from env (base64) ──────────────
SECURITY_DIR="/server/config/security"
mkdir -p "$SECURITY_DIR"
echo "[3/4] Checking certificate injection..."

if [ -n "$WORKER_CERT_B64" ]; then
    echo "$WORKER_CERT_B64" | base64 -d > "${SECURITY_DIR}/worker_cert.pem"
    echo "  [TLS] worker_cert.pem injected from env"
fi

if [ -n "$WORKER_KEY_B64" ]; then
    echo "$WORKER_KEY_B64" | base64 -d > "${SECURITY_DIR}/worker_key.pem"
    echo "  [TLS] worker_key.pem injected from env"
fi

if [ -n "$PROXY_CERT_B64" ]; then
    echo "$PROXY_CERT_B64" | base64 -d > "${SECURITY_DIR}/proxy_cert.pem"
    echo "  [TLS] proxy_cert.pem injected from env"
fi

# ── 4. Fix permissions for volume mounts ─────────────────
echo "[4/5] Fixing file permissions..."
chown -R minecraft:minecraft /server/world /server/config/security /home/minecraft

# ── 5. Start server (Switch to minecraft user) ──────
JVM_OPTS="${JVM_MAX_HEAP:--Xmx5G} ${JVM_MIN_HEAP:--Xms512M} ${JVM_EXTRA_OPTS:-}"

echo "[5/5] Starting Fabric server as 'minecraft' user..."
echo "  JVM args: $JVM_OPTS"
echo "============================================="

exec gosu minecraft java $JVM_OPTS \
    -jar /server/fabric-server-mc.1.21.1-loader.0.16.13-launcher.1.0.3.jar \
    nogui
