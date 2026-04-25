#!/bin/bash
set -e

# Function to update config.yml keys (simple sed for YAML)
apply_cfg() {
    local key="$1"
    local value="$2"
    if [ -f "config.yml" ]; then
        sed "s|^  $key:.*|  $key: $value|" config.yml > config.yml.tmp && mv config.yml.tmp config.yml || (cat config.yml | sed "s|^  $key:.*|  $key: $value|" > config.yml.tmp && cat config.yml.tmp > config.yml && rm config.yml.tmp)
        echo "  [CFG] $key = $value"
    fi
}

echo "============================================="
echo "  Freesia PROXY_Waterfall - Starting Up"
echo "============================================="

# ── 1. Apply config.yml overrides ────────────────────────
echo "[1/3] Applying config.yml overrides..."
if [ -n "$PROXY_HOST" ]; then apply_cfg "host" "$PROXY_HOST"; fi
if [ -n "$PROXY_MOTD" ]; then
    # MOTD is often multiline in YAML, using a simpler replacement here
    sed "s|motd:.*|motd: '$PROXY_MOTD'|" config.yml > config.yml.tmp && mv config.yml.tmp config.yml || (cat config.yml | sed "s|motd:.*|motd: '$PROXY_MOTD'|" > config.yml.tmp && cat config.yml.tmp > config.yml && rm config.yml.tmp)
    echo "  [CFG] motd = $PROXY_MOTD"
fi
if [ -n "$PROXY_MAX_PLAYERS" ]; then apply_cfg "player_limit" "$PROXY_MAX_PLAYERS"; fi
if [ -n "$PROXY_ONLINE_MODE" ]; then apply_cfg "online_mode" "$PROXY_ONLINE_MODE"; fi

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
chown -R waterfall:waterfall /proxy

echo "  Launch Command: java $JVM_MAX_HEAP -jar waterfall-1.21-600.jar"
echo "============================================="

# Switch to the waterfall user and start the server
exec gosu waterfall java ${JVM_MAX_HEAP:-"-Xmx1G"} ${JVM_EXTRA_OPTS} -jar waterfall-1.21-600.jar nogui
