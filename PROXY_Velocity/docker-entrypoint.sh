#!/bin/bash
set -e

# Function to update velocity.toml keys
apply_cfg() {
    local key="$1"
    local value="$2"
    if [ -f "velocity.toml" ]; then
        # Handle strings (with quotes) vs numbers/booleans
        if [[ "$value" =~ ^[0-9]+$ ]] || [[ "$value" == "true" ]] || [[ "$value" == "false" ]]; then
            sed "s|^$key = .*|$key = $value|" velocity.toml > velocity.toml.tmp && mv velocity.toml.tmp velocity.toml || (cat velocity.toml | sed "s|^$key = .*|$key = $value|" > velocity.toml.tmp && cat velocity.toml.tmp > velocity.toml && rm velocity.toml.tmp)
        else
            sed "s|^$key = .*|$key = \"$value\"|" velocity.toml > velocity.toml.tmp && mv velocity.toml.tmp velocity.toml || (cat velocity.toml | sed "s|^$key = .*|$key = \"$value\"|" > velocity.toml.tmp && cat velocity.toml.tmp > velocity.toml && rm velocity.toml.tmp)
        fi
        echo "  [CFG] $key = $value"
    fi
}

echo "============================================="
echo "  Freesia PROXY_Velocity - Starting Up"
echo "============================================="

# ── 1. Apply velocity.toml overrides ──────────────────────
echo "[1/3] Applying velocity.toml overrides..."
if [ -n "$PROXY_BIND" ]; then apply_cfg "bind" "$PROXY_BIND"; fi
if [ -n "$PROXY_MOTD" ]; then apply_cfg "motd" "$PROXY_MOTD"; fi
if [ -n "$PROXY_SHOW_MAX_PLAYERS" ]; then apply_cfg "show-max-players" "$PROXY_SHOW_MAX_PLAYERS"; fi
if [ -n "$PROXY_ONLINE_MODE" ]; then apply_cfg "online-mode" "$PROXY_ONLINE_MODE"; fi

# ── 2. Inject certificates from env (base64) ──────────────
# We place them in plugins/Freesia/security if that's where the plugin expects them
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

echo "  Launch Command: java $JVM_MAX_HEAP -jar velocity-3.4.0-SNAPSHOT-521.jar"
echo "============================================="

# Switch to the velocity user and start the server
exec gosu velocity java ${JVM_MAX_HEAP:-"-Xmx1G"} ${JVM_EXTRA_OPTS} -jar velocity-3.4.0-SNAPSHOT-521.jar nogui
