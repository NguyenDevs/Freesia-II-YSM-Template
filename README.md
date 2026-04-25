# Freesia II YSM Proxy & Worker System

A high-performance Minecraft Proxy system with integrated **Yes Steve Model (YSM)**, fully containerized using Docker for easy deployment and management.

## 🏗 System Architecture

The system consists of three main components running on a shared Docker Network (`freesia-network`):

1.  **PROXY_Velocity**: The main entry point (Port 25565), handles player routing and YSM model management.
2.  **SUB_Lobby**: The main Lobby server (Paper 1.21.8 - Port 25566), where players land initially.
3.  **MODULE_Worker**: Background server node (Fabric 1.21.1 - Port 19199), handles YSM data processing and background logic.

---

## 🚀 Quick Start Guide

### 1. Initialize Shared Network
Before running for the first time, create the network so containers can discover each other:
```bash
docker network create freesia-network
```

### 2. Launch Services
Navigate to each directory and start the services:

**Step 1: Start Proxy**
```bash
cd PROXY_Velocity
docker compose up -d
```

**Step 2: Start Sub Lobby**
```bash
cd ../SUB_Lobby
docker compose up -d
```

**Step 3: Start Worker Node**
```bash
cd ../MODULE_Worker
docker compose up -d
```

---

## 🌐 Networking & Connectivity

Depending on your deployment setup, you may need to adjust `FREESIA_MASTER_IP` in your `.env` files:

*   **Same Docker Network (Default)**: Use the container name `velocity`. Docker's internal DNS will handle the resolution.
*   **Same Machine, Different Networks**: Use `host.docker.internal` (Windows/Mac) to route through the host machine. Ensure port `19200` is exposed in Proxy's `docker-compose.yml`.
*   **Different Physical Servers (Remote)**: Use the **Public IP** of the server running the Proxy. Ensure port `19200` is open in the firewall.

---

## 🛠 Management & Commands (Console)

All containers are configured with **TTY** and **Interactive** mode enabled. You can access the live console to execute commands:

1.  **Open Console**:
    ```bash
    docker attach freesia-worker      # Manage Worker
    docker attach freesia-sub-lobby   # Manage Lobby
    docker attach freesia-velocity    # Manage Proxy
    ```
2.  **Safe Detach**: Press `Ctrl + P` followed by `Ctrl + Q`.
    *(Note: Do not press Ctrl + C as it will stop the server).*

---

## 📂 Important Directory Structure

*   `**/world`: World data (persisted on host for data safety).
*   `**/plugins` or `**/mods`: Directory for additional features and mods.
*   `**/config`: System configuration files.
*   `.gitignore`: Configured to exclude junk files, logs, and security certificates (`.pem`) from Git commits.

---

## 🔒 Security (mTLS)

The system supports mTLS between the Worker and Proxy. For mTLS to function correctly, you must **exchange certificates**:
*   The **Proxy** needs the `worker_cert.pem` to verify the Worker.
*   The **Worker** needs the `proxy_cert.pem` to verify the Proxy.

Certificates are stored at:
*   `PROXY_Velocity/plugins/Freesia/security/`
*   `MODULE_Worker/config/security/`

*(Note: These files are excluded from Git for security purposes).*

---
**Developed by NguyenDevs**
