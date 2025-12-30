#!/bin/bash
# Bootstrap script for Reachy 2 Sim Launcher
# Usage: curl -fsSL https://raw.githubusercontent.com/liveaverage/launch-brev-reachymini/main/bootstrap.sh | bash
set -e

REPO_URL="https://github.com/liveaverage/launch-brev-reachymini.git"
IMAGE="ghcr.io/liveaverage/launch-brev-reachymini:latest"
INSTALL_DIR="${INSTALL_DIR:-$HOME/launch-brev-reachymini}"
CONTAINER_NAME="interlude"

echo "════════════════════════════════════════════════════════════"
echo "  Interlude - Reachy 2 Sim Launcher"
echo "════════════════════════════════════════════════════════════"
echo ""

# Check for required tools
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is required but not installed."
    echo "   Install: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check for GPU support
if ! docker run --rm --gpus all nvidia/cuda:12.0.0-base-ubuntu22.04 nvidia-smi &> /dev/null; then
    echo "⚠️  GPU support not detected or nvidia-container-toolkit not installed"
    echo "   This deployment requires NVIDIA GPU and nvidia-container-toolkit"
    echo "   Install: https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html"
fi

# Stop any existing containers
echo "🧹 Cleaning up existing containers..."
docker rm -f "$CONTAINER_NAME" 2>/dev/null && echo "   Removed: $CONTAINER_NAME" || true

# Clone or update repo
if [ -d "$INSTALL_DIR" ]; then
    echo "📁 Directory exists: $INSTALL_DIR"
    echo "   Updating..."
    cd "$INSTALL_DIR"
    git pull --quiet 2>/dev/null || echo "   (not a git repo, skipping update)"
else
    echo "📥 Cloning repository..."
    if command -v git &> /dev/null; then
        git clone --quiet "$REPO_URL" "$INSTALL_DIR"
    else
        echo "   (git not found, using tarball)"
        mkdir -p "$INSTALL_DIR"
        curl -fsSL https://github.com/liveaverage/launch-brev-reachymini/archive/refs/heads/main.tar.gz | \
            tar -xz --strip-components=1 -C "$INSTALL_DIR"
    fi
    cd "$INSTALL_DIR"
fi

echo ""
echo "🐳 Pulling container image..."
docker pull "$IMAGE"

echo ""
echo "🚀 Starting launcher..."
echo ""

# Run the container
bash run-container.sh "$IMAGE"

echo ""
echo "════════════════════════════════════════════════════════════"
echo "  ✓ Launcher is running!"
echo ""
echo "  ┌───────────────────────────────────────────────────────┐"
echo "  │  Web Interface:                                       │"
echo "  │    http://localhost:8080                              │"
echo "  │                                                       │"
echo "  │  After deployment, access services:                  │"
echo "  │    noVNC Simulation: http://<host-ip>:6080/vnc.html  │"
echo "  │    Pipecat Dashboard: http://<host-ip>:7860          │"
echo "  └───────────────────────────────────────────────────────┘"
echo ""
echo "  📁 Config: $INSTALL_DIR/config.json"
echo "  📋 Logs:   docker logs -f $CONTAINER_NAME"
echo "  🛑 Stop:   docker stop $CONTAINER_NAME"
echo ""
echo "  📚 Docs: https://github.com/liveaverage/launch-brev-reachymini"
echo "════════════════════════════════════════════════════════════"

