#!/bin/bash
set -e

# Function to update velocity.toml keys
apply_cfg() {
    local key="$1"
    local value="$2"
    if [ -f "velocity.toml" ]; then
        if [[ "$value" =~ ^[0-9]+$ ]] || [[ "$value" == "true" ]] || [[ "$value" == "false" ]]; then
            sed -i "s|^$key = .*|$key = $value|" velocity.toml
        else
            sed -i "s|^$key = .*|$key = \"$value\"|" velocity.toml
        fi
        echo "  [CFG] $key = $value"
    fi
}

# Function to update freesia_config.toml keys
apply_freesia_cfg() {
    local key="$1"
    local value="$2"
    local file="/proxy/plugins/Freesia/freesia_config.toml"
    if [ -f "$file" ]; then
        if [[ "$value" =~ ^[0-9]+$ ]] || [[ "$value" == "true" ]] || [[ "$value" == "false" ]]; then
            sed -i "s|^$key = .*|$key = $value|" "$file"
        else
            sed -i "s|^$key = .*|$key = \"$value\"|" "$file"
        fi
        echo "  [FREESIA-CFG] $key = $value"
    fi
}

echo "============================================="
echo "  Freesia PROXY_Velocity - Starting Up"
echo "============================================="

# ── 1. Apply configuration overrides ──────────────────────
echo "[1/3] Applying configuration overrides..."

# Velocity.toml
if [ -n "$PROXY_BIND" ]; then apply_cfg "bind" "$PROXY_BIND"; fi
if [ -n "$PROXY_MOTD" ]; then apply_cfg "motd" "$PROXY_MOTD"; fi
if [ -n "$PROXY_SHOW_MAX_PLAYERS" ]; then apply_cfg "show-max-players" "$PROXY_SHOW_MAX_PLAYERS"; fi
if [ -n "$PROXY_ONLINE_MODE" ]; then apply_cfg "online-mode" "$PROXY_ONLINE_MODE"; fi
if [ -n "$PROXY_FORWARDING_MODE" ]; then apply_cfg "player-info-forwarding-mode" "$PROXY_FORWARDING_MODE"; fi
if [ -n "$PROXY_KICK_EXISTING" ]; then apply_cfg "kick-existing-players" "$PROXY_KICK_EXISTING"; fi
if [ -n "$PROXY_FORCE_KEY_AUTH" ]; then apply_cfg "force-key-authentication" "$PROXY_FORCE_KEY_AUTH"; fi

# Freesia Config
if [ -n "$PROXY_FREESIA_PORT" ]; then apply_freesia_cfg "worker_master_port" "$PROXY_FREESIA_PORT"; fi

# ── 2. Inject certificates from env (base64) ──────────────
SECURITY_DIR="/proxy/plugins/Freesia/security"
mkdir -p "$SECURITY_DIR"

echo "[2/3] Checking certificate injection..."
if [ -n "$PROXY_CERT_B64" ]; then
    echo "$PROXY_CERT_B64" | base64 -d > "${SECURITY_DIR}/proxy_cert.pem"
    echo "  [TLS] proxy_cert.pem injected"
fi
if [ -n "$PROXY_KEY_B64" ]; then
    echo "$PROXY_KEY_B64" | base64 -d > "${SECURITY_DIR}/proxy_key.pem"
    echo "  [TLS] proxy_key.pem injected"
fi

# ── 3. Start the server ──────────────────────────────────
echo "[3/3] Fixing file permissions..."
chown -R velocity:velocity /proxy

JVM_ARGS="${JVM_MAX_HEAP:-"-Xmx2G"} ${JVM_MIN_HEAP:-"-Xms512M"} ${JVM_EXTRA_OPTS}"
echo "  Launch Command: java $JVM_ARGS -jar velocity-3.4.0-SNAPSHOT-521.jar"
echo "============================================="

exec gosu velocity java $JVM_ARGS -jar velocity-3.4.0-SNAPSHOT-521.jar nogui
