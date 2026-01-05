#!/bin/bash
# Launch Reachy Mini Sim Launcher container
#
# Usage:
#   ./run-container.sh                    # Use local image
#   ./run-container.sh ghcr.io/org/repo   # Use specific image
#
# Environment variables:
#   SHOW_DRY_RUN=true       # Show dry run option (default: hidden)
#   DEPLOY_TYPE=docker-compose   # Override deployment type from config
#   LAUNCHER_PATH=/r2sim    # Subpath for deployment UI

set -e

IMAGE="${1:-ghcr.io/liveaverage/launch-brev-reachymini:latest}"
CONTAINER_NAME="interlude"
CONFIG_DIR="$(cd "$(dirname "$0")" && pwd)"
DATA_DIR="$CONFIG_DIR/.interlude-data"

# Create data directory for persistent state
mkdir -p "$DATA_DIR"

# Stop existing container if running
docker rm -f "$CONTAINER_NAME" 2>/dev/null || true

echo "Starting $CONTAINER_NAME..."
echo "  Image: $IMAGE"
echo "  Config: $CONFIG_DIR/config.json"
echo "  Docker Socket: /var/run/docker.sock"
echo "  State: $DATA_DIR"

# Build env var flags
ENV_FLAGS=""
[ -n "$SHOW_DRY_RUN" ] && ENV_FLAGS="$ENV_FLAGS -e SHOW_DRY_RUN=$SHOW_DRY_RUN"
[ -n "$DEPLOY_TYPE" ] && ENV_FLAGS="$ENV_FLAGS -e DEPLOY_TYPE=$DEPLOY_TYPE"
[ -n "$DEPLOY_HEADING" ] && ENV_FLAGS="$ENV_FLAGS -e DEPLOY_HEADING=$DEPLOY_HEADING"
[ -n "$LAUNCHER_PATH" ] && ENV_FLAGS="$ENV_FLAGS -e LAUNCHER_PATH=$LAUNCHER_PATH"

# Use host network for GPU access and direct service exposure
docker run -d \
  --name "$CONTAINER_NAME" \
  --network host \
  $ENV_FLAGS \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v "$CONFIG_DIR/config.json:/app/config.json:ro" \
  -v "$CONFIG_DIR/docker-compose.yaml:/app/docker-compose.yaml:ro" \
  -v "$CONFIG_DIR/help-content.json:/app/help-content.json:ro" \
  -v "$DATA_DIR:/app/data" \
  "$IMAGE"

echo ""
echo "✓ Container started"
echo ""
echo "  ┌───────────────────────────────────────────────────────┐"
echo "  │  Launcher:   http://localhost:9090                    │"
echo "  │                                                       │"
echo "  │  After deployment, services will be available at:    │"
echo "  │    noVNC:     http://<host-ip>:6080/vnc.html         │"
echo "  │    Pipecat:   http://<host-ip>:7860                  │"
echo "  └───────────────────────────────────────────────────────┘"
echo ""
echo "  Logs: docker logs -f $CONTAINER_NAME"
echo "  Stop: docker stop $CONTAINER_NAME"
echo ""

