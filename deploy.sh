#!/bin/bash

# Exit on any error
set -e

# --- CONFIGURATION ---
APP_NAME="node-app"
IMAGE_NAME="hengkakada/node-app"
IMAGE_TAG=$1  # Passed from Jenkins ${env.BUILD_NUMBER}
NGINX_CONF="/etc/nginx/conf.d/app.conf"

if [ -z "$IMAGE_TAG" ]; then
    echo "❌ Error: No Build Tag provided. Usage: ./deploy.sh <tag>"
    exit 1
fi

# 1. Determine which "color" is currently active
# We check which port Nginx is currently routing to
if grep -q "3001" "$NGINX_CONF"; then
    CURRENT_COLOR="blue"
    TARGET_COLOR="green"
    TARGET_PORT=3002
    OLD_PORT=3001
else
    CURRENT_COLOR="green"
    TARGET_COLOR="blue"
    TARGET_PORT=3001
    OLD_PORT=3002
fi

echo "🚀 Starting Deployment of version $IMAGE_TAG"
echo "Current active environment: $CURRENT_COLOR (Port $OLD_PORT)"
echo "Target environment: $TARGET_COLOR (Port $TARGET_PORT)"

# 2. Prepare Environment Variables for Docker Compose
export IMAGE_NAME=$IMAGE_NAME
export IMAGE_TAG=$IMAGE_TAG
export CONTAINER_NAME="$APP_NAME-$TARGET_COLOR"
export HOST_PORT=$TARGET_PORT

# 3. Pull and Start the New Container
echo "📥 Pulling new image..."
docker compose pull

echo "🏗️ Starting new container..."
docker compose up -d

# 4. Health Check
# We wait for the Node.js /health endpoint to return HTTP 200
echo "🔍 Performing Health Check on port $TARGET_PORT..."
MAX_RETRIES=12
COUNT=0

while [ $COUNT -lt $MAX_RETRIES ]; do
    # -s: silent, -f: fail on 4xx/5xx
    if curl -s -f "http://localhost:$TARGET_PORT/health" > /dev/null; then
        echo "✅ Health Check Passed!"
        HEALTH_PASSED=true
        break
    fi
    echo "Wait for app to be ready... ($((COUNT+1))/$MAX_RETRIES)"
    sleep 5
    COUNT=$((COUNT+1))
done

# 5. Switch Traffic or Rollback
if [ "$HEALTH_PASSED" = true ]; then
    echo "🔄 Swapping Nginx traffic to $TARGET_COLOR..."
    # Replace the old port with the new port in Nginx config
    sudo sed -i "s/127.0.0.1:$OLD_PORT/127.0.0.1:$TARGET_PORT/" "$NGINX_CONF"
    
    # Reload Nginx without dropping connections
    sudo nginx -t && sudo nginx -s reload
    
    echo "🧹 Shutting down old $CURRENT_COLOR container..."
    docker stop "$APP_NAME-$CURRENT_COLOR" || true
    docker rm "$APP_NAME-$CURRENT_COLOR" || true
    
    echo "✨ Deployment Successful! Version $IMAGE_TAG is now LIVE."
else
    echo "❌ HEALTH CHECK FAILED!"
    echo "🛑 Keeping $CURRENT_COLOR live. Shutting down failed $TARGET_COLOR container..."
    docker stop "$APP_NAME-$TARGET_COLOR" || true
    docker rm "$APP_NAME-$TARGET_COLOR" || true
    exit 1
fi