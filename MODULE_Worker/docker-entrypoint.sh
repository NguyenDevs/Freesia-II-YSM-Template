#!/bin/bash
set -e

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
            sed "s|^${key}=.*|${key}=${value}|" "$PROPS_FILE" > "$PROPS_FILE.tmp" && cat "$PROPS_FILE.tmp" > "$PROPS_FILE" && rm "$PROPS_FILE.tmp"
        else
            echo "${key}=${value}" >> "$PROPS_FILE"
        fi
        echo "  [PROPS] ${key} = ${value}"
    fi
}

echo "[1/5] Applying server.properties overrides..."
apply_prop "server-port"                  "${MC_PORT:-19199}"
apply_prop "server-ip"                    "${MC_BIND_IP:-0.0.0.0}"
apply_prop "max-players"                  "${MC_MAX_PLAYERS:-2000}"
apply_prop "online-mode"                  "${MC_ONLINE_MODE:-false}"
apply_prop "motd"                         "${MC_MOTD:-Freesia Worker Node}"
apply_prop "difficulty"                   "${MC_DIFFICULTY:-peaceful}"
apply_prop "gamemode"                     "${MC_GAMEMODE:-survival}"
apply_prop "pvp"                          "${MC_PVP:-false}"
apply_prop "allow-nether"                 "${MC_ALLOW_NETHER:-false}"
apply_prop "generate-structures"          "${MC_GENERATE_STRUCTURES:-false}"
apply_prop "view-distance"                "${MC_VIEW_DISTANCE:-1}"
apply_prop "simulation-distance"          "${MC_SIMULATION_DISTANCE:-1}"
apply_prop "network-compression-threshold" "${MC_COMPRESSION_THRESHOLD:-256}"
apply_prop "prevent-proxy-connections"     "${MC_PREVENT_PROXY:-false}"
apply_prop "enforce-secure-profile"       "${MC_ENFORCE_SECURE_PROFILE:-false}"
apply_prop "spawn-animals"                "${MC_SPAWN_ANIMALS:-false}"
apply_prop "spawn-monsters"               "${MC_SPAWN_MONSTERS:-false}"
apply_prop "spawn-npcs"                   "${MC_SPAWN_NPCS:-false}"
apply_prop "max-tick-time"                "${MC_MAX_TICK_TIME:-60000}"
apply_prop "log-ips"                      "${MC_LOG_IPS:-false}"
apply_prop "level-type"                   "${MC_LEVEL_TYPE:-flat}"
apply_prop "sync-chunk-writes"            "${MC_SYNC_CHUNK_WRITES:-false}"
apply_prop "entity-broadcast-range-percentage" "${MC_ENTITY_BROADCAST:-10}"

# ── 2. Override freesia_config.toml from env variables ──────
FREESIA_CFG="/server/config/freesia_config.toml"

apply_freesia_cfg() {
    local key="$1"
    local value="$2"
    if [ -f "$FREESIA_CFG" ]; then
        if [[ "$value" =~ ^[0-9]+$ ]] || [[ "$value" == "true" ]] || [[ "$value" == "false" ]]; then
            sed "s|^$key = .*|$key = $value|" "$FREESIA_CFG" > "$FREESIA_CFG.tmp" && cat "$FREESIA_CFG.tmp" > "$FREESIA_CFG" && rm "$FREESIA_CFG.tmp"
        else
            sed "s|^$key = .*|$key = \"$value\"|" "$FREESIA_CFG" > "$FREESIA_CFG.tmp" && cat "$FREESIA_CFG.tmp" > "$FREESIA_CFG" && rm "$FREESIA_CFG.tmp"
        fi
        echo "  [FREESIA-CFG] ${key} = ${value}"
    fi
}

echo "[2/5] Applying freesia_config.toml overrides..."
apply_freesia_cfg "worker_master_ip"       "${FREESIA_MASTER_IP:-host.docker.internal}"
apply_freesia_cfg "worker_master_port"     "${FREESIA_MASTER_PORT:-19200}"
apply_freesia_cfg "controller_reconnect_interval" "${FREESIA_RECONNECT_INTERVAL:-1}"
apply_freesia_cfg "player_data_cache_invalidate_interval_seconds" "${FREESIA_CACHE_INVALIDATE:-30}"
apply_freesia_cfg "enable_tls"             "${FREESIA_TLS_ENABLED:-true}"
apply_freesia_cfg "trust_all_certificates" "${FREESIA_TRUST_ALL:-false}"

# ── 3. Inject certificates from env (optional) ──────────────
SECURITY_DIR="/server/config/security"
mkdir -p "$SECURITY_DIR"

echo "[3/5] Checking certificate injection..."
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

# ── 4. Fix permissions (Selective to avoid hanging on large volumes) ──
echo "[4/5] Fixing file permissions..."
# Only chown specific directories that are likely to be written to
chown minecraft:minecraft /server
chown -R minecraft:minecraft /server/world /server/logs /server/config /home/minecraft 2>/dev/null || true

# ── 5. Start server (Switch to minecraft user) ────────────────
JVM_OPTS="${JVM_MAX_HEAP:--Xmx5G} ${JVM_MIN_HEAP:--Xms512M} ${JVM_EXTRA_OPTS:-}"

echo "[5/5] Starting Fabric server as 'minecraft' user..."
echo "  JVM args: $JVM_OPTS"
echo "============================================="

exec gosu minecraft java $JVM_OPTS \
    -jar /server/fabric-server-mc.1.21.1-loader.0.16.13-launcher.1.0.3.jar \
    nogui
