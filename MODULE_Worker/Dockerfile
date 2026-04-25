# =========================================================
# Freesia Worker - Fabric Minecraft Server (1.21.1)
# Image: freesia/module-worker
# =========================================================

FROM eclipse-temurin:21-jre-jammy

LABEL maintainer="nguyendevs"
LABEL description="Freesia Worker Node - Fabric Minecraft 1.21.1"
LABEL version="1.0.4"

# ── Install necessary tools ──────────────────────────
RUN apt-get update && apt-get install -y bash curl tzdata gosu \
    && ln -sf /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime \
    && echo "Asia/Ho_Chi_Minh" > /etc/timezone \
    && rm -rf /var/lib/apt/lists/*

# ── Create non-root user ────────────────────────
RUN groupadd -g 1000 minecraft && \
    useradd -u 1000 -g minecraft -m -s /bin/bash minecraft

# ── Working directory ────────────────────────────────────
WORKDIR /server

# ── Environment variable for Home ───────────────────────────
ENV HOME=/home/minecraft

# ── Create directories and set recursive permissions ──────────────────────
RUN mkdir -p /server/world /server/config/security \
    && chown -R minecraft:minecraft /server /home/minecraft

# ── Copy entire server into image ───────────────────
COPY --chown=minecraft:minecraft . /server/

# ── EULA pre-accepted ──────────────────────────
RUN echo "eula=true" > /server/eula.txt

# ── Script entrypoint ────────────────────────────────────
COPY --chown=minecraft:minecraft docker-entrypoint.sh /server/docker-entrypoint.sh
RUN chmod +x /server/docker-entrypoint.sh

# ── Entrypoint will run as root to fix permissions first ──
# ── Then switch to minecraft user ──────────────────
# USER minecraft (Removed to allow entrypoint to run as root)

# ── Minecraft Port ───────────────────────────────────────
EXPOSE 19199

# ── Volume for world data & config ──────────────────────
# ── Removed VOLUME to prevent masking host-mounted directories ──
# VOLUME ["/server/world", "/server/config/security"]


ENTRYPOINT ["/server/docker-entrypoint.sh"]
