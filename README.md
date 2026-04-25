# Freesia MODULE_Worker — Fabric Minecraft Node

A high-performance, containerized background server for the Freesia system, optimized for **Yes Steve Model (YSM)** and Netty-based communication.

## 🚀 Docker Setup (Recommended)

Docker is the preferred way to run the Worker node as it ensures a consistent environment and automatic configuration management.

### 1. Prerequisites
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed and running.
- Basic knowledge of terminal/command prompt.

### 2. Configuration
Create/edit the `.env` file in the root directory. This file controls almost all server settings:

| Variable | Description | Default |
| :--- | :--- | :--- |
| `JVM_MAX_HEAP` | Maximum RAM allocated to Java | `-Xmx5G` |
| `MC_PORT` | Port for Minecraft/Query | `19199` |
| `FREESIA_MASTER_IP` | IP of the Proxy/Controller | `host.docker.internal` |
| `MC_ONLINE_MODE` | Set to `false` for cracked/proxy mode | `false` |

### 3. Launching
Open your terminal in this folder and run:
```bash
docker compose up -d
```
The server will start in the background. You can check the logs with:
```bash
docker logs -f freesia-worker
```

### 4. Data Persistence
The following directories and files are mapped to your host machine for safety:
- `./world`: Your world data.
- `./config`: All configuration files (including `security/` for certs).
- `./mods`: Add your `.jar` mods here.
- `./logs`: Server log history.
- `ops.json`, `whitelist.json`, etc.: Admin settings.

---

## 💻 Local Execution (Run.Bat)

If you prefer to run the server directly on your Windows machine without Docker.

### 1. Prerequisites
- **Java 21** (Required) must be installed and added to your PATH.
- Verify with `java -version`.

### 2. Configuration Adjustments
**Crucial:** When running locally, the automatic synchronization from `.env` to `server.properties` **does not occur**.
- You must manually edit `server.properties` and `config/freesia_config.toml`.
- **IP Change:** In `config/freesia_config.toml`, change `worker_master_ip` to `127.0.0.1` (instead of `host.docker.internal`).

### 3. Launching
Double-click `Run.Bat`. Ensure your RAM settings in the script match your machine's capacity.

---

## 🛠 Advanced Optimization
This worker is configured as a **Background Node** by default:
- **View Distance:** 1
- **Spawn Animals/Monsters:** Disabled
- **World Type:** Flat
- **Sync Chunk Writes:** Disabled

These settings minimize CPU and RAM usage, allowing the server to focus entirely on YSM model processing and network communication.

---

## 🔒 Security (mTLS)
If using mTLS, place your certificates in:
- `config/security/worker_cert.pem`
- `config/security/worker_key.pem`
- `config/security/proxy_cert.pem` (Trust anchor)

Alternatively, you can inject these via Base64 in the `.env` file for Docker deployments.
