<h1 align="center">🚀 Reachy Mini Sim Launcher</h1>

<p align="center">
  <strong>One-click web interface for deploying Reachy Mini simulation with Pipecat AI</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Docker-Compose-2496ED?style=for-the-badge&logo=docker&logoColor=white" alt="Docker Compose"/>
  <img src="https://img.shields.io/badge/NVIDIA-GPU%20Required-76B900?style=for-the-badge&logo=nvidia&logoColor=white" alt="NVIDIA GPU"/>
  <img src="https://img.shields.io/badge/Flask-Backend-000000?style=for-the-badge&logo=flask&logoColor=white" alt="Flask"/>
  <img src="https://img.shields.io/badge/Pipecat-AI-00d4aa?style=for-the-badge" alt="Pipecat AI"/>
</p>

<p align="center">
  <em>Built on the <strong>Interlude</strong> framework—a generic deployment launcher for containerized applications</em>
</p>

---


## 🚀 Quick Start

### Deploy Instantly with NVIDIA Brev

<p align="center">
  <em>Skip the setup—launch a fully configured Reachy Mini simulation environment in seconds</em>
</p>

<table align="center">
<thead>
<tr>
<th align="center">GPU</th>
<th align="center">VRAM</th>
<th align="center">Best For</th>
<th align="center">Deploy</th>
</tr>
</thead>
<tbody>
<tr>
<td align="center"><strong>🔵 NVIDIA L4</strong></td>
<td align="center">24 GB</td>
<td align="center">General Simulation & Training</td>
<td align="center"><a href="https://brev.nvidia.com/launchable/deploy?launchableID=env-37ZZY950tDIuCQSSHXIKSGpRbFJ"><img src="https://brev-assets.s3.us-west-1.amazonaws.com/nv-lb-dark.svg" alt="Deploy on Brev" height="40"/></a></td>
</tr>
</tbody>
</table>

<p align="center">
  <sub>☝️ Click a deploy button above to launch on <a href="https://brev.nvidia.com">Brev</a> — GPU cloud for AI developers</sub>
</p>

### One-Line Bootstrap (Recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/liveaverage/launch-brev-reachymini/main/bootstrap.sh | bash
```

**What it does:**
- ✅ Clones the repository
- ✅ Pulls container image (`ghcr.io/liveaverage/launch-brev-reachymini:latest`)
- ✅ Starts the launcher on port 8080
- ✅ Exposes web UI at `http://localhost:8080`

<details>
<summary><strong>📂 Custom Install Directory</strong></summary>

```bash
INSTALL_DIR=/opt/reachy-launcher curl -fsSL https://raw.githubusercontent.com/liveaverage/launch-brev-reachymini/main/bootstrap.sh | bash
```

</details>

---

## 📋 Prerequisites

| Requirement | Details |
|:------------|:--------|
| **Docker** | Docker Compose V2 (or legacy `docker-compose`) |
| **GPU** | NVIDIA GPU with drivers 525.60.13+ |
| **Toolkit** | nvidia-container-toolkit configured |
| **API Keys** | NVIDIA ([build.nvidia.com](https://build.nvidia.com/)) + ElevenLabs ([elevenlabs.io](https://elevenlabs.io/)) |

> **Note:** The launcher auto-detects `docker compose` (V2) or `docker-compose` (V1). Both are supported.

<details>
<summary><strong>🔍 Verify GPU Access</strong></summary>

```bash
docker run --rm --gpus all nvidia/cuda:12.0.0-base-ubuntu22.04 nvidia-smi
```

If this fails, install [nvidia-container-toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html).

</details>

---

## 🎯 Usage

<table>
<tr>
<th>Step</th>
<th>Action</th>
</tr>
<tr>
<td>1️⃣</td>
<td>Open <code>http://localhost:8080</code> in your browser</td>
</tr>
<tr>
<td>2️⃣</td>
<td>Enter <strong>NVIDIA API Key</strong> (<code>nvapi-...</code>) and <strong>ElevenLabs API Key</strong> (<code>sk_...</code>)</td>
</tr>
<tr>
<td>3️⃣</td>
<td>Click <strong>🤙 Let it rip</strong> to deploy</td>
</tr>
<tr>
<td>4️⃣</td>
<td>Monitor real-time logs as the container pulls and starts</td>
</tr>
<tr>
<td>5️⃣</td>
<td>Access services via generated links</td>
</tr>
</table>

### 🌐 Service Links

After deployment completes, clickable service links appear:

| Service | Port | Description |
|:--------|:-----|:------------|
| **🖥️ noVNC Simulation** | 6080 | Interactive robot simulation via noVNC |
| **🤖 Pipecat Dashboard** | 7860 | Pipecat AI control interface |

Links are automatically configured:
- Via public IP: `https://<HOST_IP>:6080/vnc.html`
- Via domain tunnel: Uses extracted `BASE_DOMAIN` for service URLs

### 🗑️ Uninstalling

Click **Uninstall** to:
- Stop and remove the container
- Clean up deployment state and `.env` file
- Keep cached Docker image for faster redeployment

---

## ⚙️ Configuration

### 🔐 Secret Persistence with `.env` Files

**Like Kubernetes secrets, but for Docker Compose.**

API keys entered via the launcher are automatically persisted to a `.env` file:

✅ **Secrets survive launcher restarts**  
✅ **Manual `docker-compose` commands work seamlessly**  
✅ **Container restarts preserve configuration**  
✅ **Standard Docker Compose practice**

**Security:**
- File permissions: `600` (owner read/write only)
- Excluded from git via `.gitignore`
- Automatically cleaned up on uninstall

<details>
<summary><strong>🔧 Manual Operations</strong></summary>

```bash
# View persisted secrets (be careful!)
cat .env

# Manual docker-compose operations
docker compose restart
docker compose down && docker compose up -d

# Clean up
rm .env
```

</details>

### 🔗 Service Links with Runtime Substitution

Service URLs support dynamic variables resolved at deployment time:

```json
{
  "services": [
    {
      "name": "Open noVNC Simulation",
      "url": "https://${HOST_IP}:6080/vnc.html",
      "description": "Interactive robot simulation via noVNC"
    }
  ]
}
```

**Available Variables:**
- `${HOST_IP}` - Public IP from `curl icanhazip.com`
- `${BASE_DOMAIN}` - Domain suffix extracted from Host header
  - Example: `studio-lccpkmz8f.brevlab.com` → `-lccpkmz8f.brevlab.com`
  - Example: `interlude0-uplcf60xo.brevlab.com` → `0-uplcf60xo.brevlab.com`
  - Usage: `https://novnc${BASE_DOMAIN}` → `https://novnc-lccpkmz8f.brevlab.com` or `https://novnc0-uplcf60xo.brevlab.com`

### 🎨 Customization

<details>
<summary><strong>➕ Adding New Input Fields</strong></summary>

Edit `config.json`—no code changes needed:

```json
{
  "input_fields": [
    {
      "id": "myNewField",
      "label": "My New Field",
      "type": "text",
      "placeholder": "Enter value...",
      "env_var": "MY_ENV_VAR",
      "required": false
    }
  ]
}
```

</details>

<details>
<summary><strong>🖼️ Changing the Logo</strong></summary>

Replace `assets/nvidia-logo.svg` or modify the inline SVG in `index.html`.

</details>

<details>
<summary><strong>🎨 Styling</strong></summary>

All styles live in `<style>` section of `index.html`:
- Background: `#181818`
- Primary Green: `#76b900`
- Input Background: `rgba(255, 255, 255, 0.05)`

</details>

---

## 🏗️ Architecture

### Frontend (SPA)
- Pure JavaScript (no framework dependencies)
- Dynamic form generation from `config.json`
- Server-Sent Events (SSE) for real-time log streaming
- Deployment state management with history mode

### Backend (Flask)
- Lightweight Python Flask application
- Dynamic input field handling
- Streaming command execution with real-time output
- Persistent deployment state tracking (`.state` file)
- Environment variable mapping for Docker Compose

### Container Configuration

| Setting | Value | Purpose |
|:--------|:------|:--------|
| **Image** | `ghcr.io/liveaverage/reachy-mini-pipecat:latest` | Pre-built simulation image |
| **Network** | `host` | Required for Isaac Sim |
| **GPU** | All NVIDIA GPUs | Full capabilities passthrough |
| **Memory** | 2GB shared | Rendering buffer |

### File Structure

```
.
├── app.py                      # Flask backend with dynamic field support
├── index.html                  # Frontend SPA with dynamic form rendering
├── config.json                 # Deployment configuration with input fields
├── docker-compose.yaml         # Reachy simulation container definition
├── help-content.json           # Help documentation content
├── requirements.txt            # Python dependencies
├── assets/                     # Static assets (logos, etc.)
├── Dockerfile                  # Launcher containerization
├── bootstrap.sh                # One-line installer
└── README.md                   # This file
```

---

## 🔥 Troubleshooting

<details>
<summary><strong>❌ Container Fails to Start</strong></summary>

**Symptom:** Container exits immediately after start

**Solution:**
```bash
# Check GPU drivers
nvidia-smi

# Verify nvidia-container-toolkit
docker run --rm --gpus all nvidia/cuda:12.0.0-base-ubuntu22.04 nvidia-smi

# Check logs
docker logs reachy_pipecat
```

</details>

<details>
<summary><strong>❌ API Key Errors</strong></summary>

**Symptom:** Authentication failures in logs

**Solution:**
1. Verify NVIDIA API key at https://build.nvidia.com/
2. Verify ElevenLabs API key at https://elevenlabs.io/
3. Ensure keys have not expired
4. Check for copy/paste errors (extra spaces, truncation)

</details>

<details>
<summary><strong>❌ Slow Startup / Long Pull Times</strong></summary>

**Symptom:** Deployment takes 10+ minutes

**Explanation:**
- First pull downloads large image (~10GB)
- Subsequent deployments use cached image
- Check network speed and Docker Hub connectivity

</details>

<details>
<summary><strong>❌ Port Conflicts</strong></summary>

**Symptom:** Cannot bind to port

**Solution:**
```bash
# Check for conflicting services
sudo netstat -tulpn | grep -E '6080|7860'

# Stop conflicting services or modify docker-compose.yaml
```

</details>

<details>
<summary><strong>❌ Permission Denied on Docker Socket</strong></summary>

**Symptom:** Cannot connect to Docker daemon

**Solution:**
```bash
# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Or run with sudo (not recommended for production)
sudo ./run-native.sh
```

</details>

<details>
<summary><strong>🐛 Development Mode</strong></summary>

Run locally without Docker:

```bash
# Install dependencies
pip install -r requirements.txt

# Run the server
python app.py
```

Access at `http://localhost:8080`

</details>

---

## 🌍 Environment Variables

Configure via environment variables:

| Variable | Default | Description |
|:---------|:--------|:------------|
| `DEPLOY_TYPE` | `docker-compose` | Active deployment type from config |
| `DEPLOY_HEADING` | `Deploy Reachy Mini Sim` | Custom heading |
| `PROJECT_NAME` | `Reachy Mini Sim` | Browser tab title |
| `LAUNCHER_PATH` | `/interlude` | Base path for reverse proxy |
| `STATE_FILE` | `/app/data/deployment.state` | Persistent state location |

---

## 📚 API Endpoints

<details>
<summary><strong>View Available Endpoints</strong></summary>

```bash
# Check configuration
curl http://localhost:8080/config

# Check deployment state
curl http://localhost:8080/state

# View help content
curl http://localhost:8080/help
```

</details>

---

<p align="center">
  <sub>Built on the <strong>Interlude</strong> framework • MIT License</sub>
</p>
