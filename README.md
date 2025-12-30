# Reachy 2 Sim Deployment Launcher

A web-based deployment launcher for the Reachy 2 humanoid robot simulation with Pipecat AI integration. Provides a clean, secure interface for deploying and managing the simulation container with GPU acceleration.

## Features

- **Single-page web interface** styled after the Brev/NVIDIA console design
- **Dynamic input fields** for NVIDIA and ElevenLabs API keys
- **Docker Compose deployment** with GPU passthrough and host networking
- **Real-time streaming logs** during deployment
- **Deployment state management** with uninstall capability
- **Lightweight Flask backend** with minimal dependencies

## Quick Start

### One-Line Bootstrap (Recommended)

Install and run everything with a single command:

```bash
curl -fsSL https://raw.githubusercontent.com/liveaverage/launch-brev-reachymini/main/bootstrap.sh | bash
```

Or with custom install directory:

```bash
INSTALL_DIR=/opt/r2sim-launcher curl -fsSL https://raw.githubusercontent.com/liveaverage/launch-brev-reachymini/main/bootstrap.sh | bash
```

**What it does:**
- Clones the repository
- Pulls the latest container image (`ghcr.io/liveaverage/launch-brev-reachymini:latest`)
- Configures and starts the launcher
- Exposes the web UI on port 8080

### Prerequisites

- Docker installed and running with GPU support
- NVIDIA GPU with drivers installed (525.60.13 or newer)
- nvidia-container-toolkit configured
- Python 3.8+ (for native mode) or Docker (for containerized mode)
- API Keys:
  - NVIDIA API Key from https://build.nvidia.com/
  - ElevenLabs API Key from https://elevenlabs.io/

### Verify GPU Access

```bash
docker run --rm --gpus all nvidia/cuda:12.0.0-base-ubuntu22.04 nvidia-smi
```

If this fails, install nvidia-container-toolkit:
https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html

## Deployment Options

### Option 1: Native Mode (Recommended)

Run directly on your host without containerization. Best for local development.

```bash
./run-native.sh
```

**Pros:**
- No Docker socket mounting required
- Direct access to host GPU
- Simpler debugging
- Faster startup

**Cons:**
- Requires Python 3 and Flask installed locally

### Option 2: Containerized Launcher

Build and run the launcher itself in a container:

```bash
# Build the launcher image
docker build -t r2sim-launcher .

# Run with Docker socket access
docker run -d \
  -p 8080:8080 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $(pwd)/config.json:/app/config.json:ro \
  -v $(pwd)/docker-compose.yaml:/app/docker-compose.yaml:ro \
  --name r2sim-launcher \
  r2sim-launcher
```

### Access the Application

Open your browser and navigate to:
```
http://localhost:8080
```

Or if using a custom launcher path (e.g., behind a reverse proxy):
```
http://your-domain.com/r2sim
```

## Configuration

### Dynamic Input Fields

The launcher uses a flexible input field system defined in `config.json`:

```json
{
  "docker-compose": {
    "input_fields": [
      {
        "id": "nvidiaApiKey",
        "label": "NVIDIA API Key",
        "type": "password",
        "placeholder": "nvapi-...",
        "env_var": "NVIDIA_API_KEY",
        "required": true
      },
      {
        "id": "elevenlabsApiKey",
        "label": "ElevenLabs API Key",
        "type": "password",
        "placeholder": "sk_...",
        "env_var": "ELEVENLABS_API_KEY",
        "required": true
      }
    ]
  }
}
```

### Secret Persistence with `.env` Files

**Like Kubernetes secrets, but for Docker Compose.**

API keys and secrets entered via the launcher are automatically persisted to a `.env` file in the working directory. This ensures:

✅ **Secrets persist across launcher restarts**  
✅ **Manual `docker-compose` commands work without re-entering keys**  
✅ **Container restarts preserve configuration**  
✅ **Standard Docker Compose practice**

**How it works:**
1. User enters API keys via web interface
2. Backend writes `.env` file with secure permissions (600 - owner only)
3. Docker Compose automatically reads `.env` for variable substitution
4. Keys persist until explicit uninstall

**Security:**
- File permissions: `600` (owner read/write only)
- Excluded from git via `.gitignore`
- Automatically cleaned up on uninstall
- Only whitelisted environment variables are written

**Manual access:**
```bash
# View your persisted secrets (be careful!)
cat .env

# Manual docker-compose operations work seamlessly
docker-compose restart
docker-compose down && docker-compose up -d

# Clean up (also done automatically via uninstall button)
rm .env
```

### Service Links with Runtime URL Substitution

After successful deployment, the launcher displays clickable links to available services. URLs support runtime variable substitution:

```json
{
  "docker-compose": {
    "services": [
      {
        "name": "Open noVNC Simulation",
        "url": "https://${HOST_IP}:6080/vnc.html",
        "description": "Interactive robot simulation via noVNC"
      },
      {
        "name": "Open Pipecat Dashboard",
        "url": "https://${HOST_IP}:7860",
        "description": "Pipecat AI control interface"
      }
    ]
  }
}
```

**Available Variables:**
- `${HOST_IP}` - Public IP address derived from `curl icanhazip.com`
- `${BASE_DOMAIN}` - Domain suffix extracted from the Host header
  - Example: `studio-lccpkmz8f.brevlab.com` → `-lccpkmz8f.brevlab.com`
  - Usage: `https://dash${BASE_DOMAIN}` → `https://dash-lccpkmz8f.brevlab.com`

**How it works:**
1. During deployment, the backend derives `HOST_IP` and `BASE_DOMAIN`
2. Template variables in service URLs are substituted with actual values
3. Resolved URLs are saved to persistent state
4. Frontend displays service links after deployment and in history mode

### Input Field Schema

Each field supports:
- `id`: Unique identifier for the field
- `label`: Display label in the UI
- `type`: Input type (text, password, etc.)
- `placeholder`: Placeholder text
- `env_var`: Environment variable name to set in the container
- `required`: Whether the field is required (boolean)

This flexible system allows you to add/remove/modify input fields without changing the HTML or JavaScript.

### Deployment Commands

Commands are defined in `config.json`:

```json
{
  "docker-compose": {
    "pre_commands": [
      "docker-compose -f docker-compose.yaml pull"
    ],
    "command": "docker-compose -f docker-compose.yaml up -d",
    "uninstall_commands": [
      "docker-compose -f docker-compose.yaml down",
      "docker-compose -f docker-compose.yaml rm -f"
    ]
  }
}
```

## Architecture

### Frontend (SPA)
- Pure JavaScript (no framework dependencies)
- Dynamic form generation from config
- Server-Sent Events (SSE) for real-time log streaming
- Deployment state management with history mode

### Backend (Flask)
- Lightweight Python Flask application
- Dynamic input field handling
- Streaming command execution with real-time output
- Persistent deployment state tracking
- Environment variable mapping for Docker Compose

### Container Configuration
- Image: `ghcr.io/liveaverage/reachy-mini-pipecat:latest`
- Network: Host mode (required for Isaac Sim)
- GPU: All NVIDIA GPUs with full capabilities
- Memory: 2GB shared memory for rendering

## File Structure

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
├── run-native.sh               # Native execution script
└── README.md                   # This file
```

## Usage

1. **Open the launcher** at `http://localhost:8080`
2. **Enter API keys**:
   - NVIDIA API Key (nvapi-...)
   - ElevenLabs API Key (sk_...)
3. **Click "🤙 Let it rip"** to deploy
4. **Monitor real-time logs** as the container pulls and starts
5. **Access services** via the links displayed after deployment completes:
   - noVNC Simulation at port 6080
   - Pipecat Dashboard at port 7860

### Service Links

After successful deployment, clickable service links appear in:
- **Success banner** at the end of streaming logs
- **Persistent service links section** below the deployment status
- **History mode** when you revisit after deployment

Links are automatically configured based on your access method:
- Via public IP: `https://<host-ip>:6080/vnc.html`
- Via domain with tunnel: Uses extracted base domain for service URLs

### Uninstalling

Click the **🗑️ Uninstall** button to:
- Stop the running container
- Remove container resources
- Clear deployment state
- Keep the cached Docker image for faster redeployment

## Customization

### Adding New Input Fields

Edit `config.json` to add new fields:

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

The frontend and backend automatically adapt to new fields - no code changes needed!

### Changing the Logo

Replace `assets/nvidia-logo.svg` or modify the SVG in `index.html`.

### Styling

All styles are in the `<style>` section of `index.html`:
- Background: `#181818`
- Primary Green: `#76b900`
- Input Background: `rgba(255, 255, 255, 0.05)`

### Help Content

Edit `help-content.json` to customize the help modal content. Supports:
- Markdown-style formatting (`**bold**`, `code`)
- Multiple sections with icons
- Links (auto-detected)

## Security Considerations

- **API keys persisted to `.env` file** with 600 permissions (owner only)
- **`.env` excluded from git** via `.gitignore` - never committed
- **Automatic cleanup** on uninstall removes `.env` file
- Input fields use `type="password"` for visual masking in browser
- Container runs with user-specified privileges (no forced root)
- Host network mode required for Isaac Sim but limits network isolation
- Keys stored as plaintext in `.env` - ensure proper host security
- Only whitelisted environment variables written to `.env`

## Troubleshooting

### Container Fails to Start

**Symptom**: Container exits immediately after start  
**Solution**: 
1. Check GPU drivers: `nvidia-smi`
2. Verify nvidia-container-toolkit: `docker run --rm --gpus all nvidia/cuda:12.0.0-base-ubuntu22.04 nvidia-smi`
3. Check logs: `docker logs reachy_pipecat`

### API Key Errors

**Symptom**: Authentication failures in logs  
**Solution**: 
1. Verify NVIDIA API key at https://build.nvidia.com/
2. Verify ElevenLabs API key at https://elevenlabs.io/
3. Ensure keys have not expired
4. Check for copy/paste errors (extra spaces, truncation)

### Slow Startup

**Symptom**: Deployment takes 10+ minutes  
**Solution**: 
- First pull downloads large image (~10GB)
- Subsequent deployments use cached image
- Check network speed and Docker Hub connectivity

### Port Conflicts

**Symptom**: Cannot bind to port  
**Solution**: 
- Host network mode uses all ports the container needs
- Check for conflicting services: `sudo netstat -tulpn`
- Stop conflicting services or modify container configuration

### Permission Denied on Docker Socket

**Symptom**: Cannot connect to Docker daemon  
**Solution**:
```bash
# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Or run with sudo (not recommended for production)
sudo ./run-native.sh
```

## Development

Run locally without Docker:

```bash
# Install dependencies
pip install -r requirements.txt

# Run the server
python app.py
```

The application will be available at `http://localhost:8080`

## Environment Variables

Configure via environment variables:

```bash
export DEPLOY_TYPE="docker-compose"        # Active deployment type from config
export DEPLOY_HEADING="Deploy Reachy Sim"  # Custom heading
export PROJECT_NAME="Reachy 2 Sim"         # Browser tab title
export LAUNCHER_PATH="/r2sim"              # Base path for reverse proxy
export STATE_FILE="/app/data/deployment.state"  # Persistent state location
```

## Testing

### Verify Configuration

Check config endpoint:
```bash
curl http://localhost:8080/config
```

### Check Deployment State

```bash
curl http://localhost:8080/state
```

### View Help Content

```bash
curl http://localhost:8080/help
```

## License

MIT
