#!/bin/bash
set -euo pipefail

ACTIVE_LINK="/usr/share/nginx/html"
BLUE_DIR="/var/www/blue"
GREEN_DIR="/var/www/green"
HEALTH_URL="http://localhost/"

ACTIVE_TARGET="$(readlink -f "$ACTIVE_LINK" || true)"

if [ "$ACTIVE_TARGET" = "$BLUE_DIR" ]; then
  TARGET_DIR="$GREEN_DIR"
  TARGET_COLOR="green"
  ACTIVE_COLOR="blue"
else
  TARGET_DIR="$BLUE_DIR"
  TARGET_COLOR="blue"
  ACTIVE_COLOR="green"
fi

echo "Active is: $ACTIVE_COLOR"
echo "Deploying to inactive: $TARGET_COLOR"

sudo mkdir -p "$TARGET_DIR"
sudo rm -rf "${TARGET_DIR:?}/"*
sudo cp -r app/* "$TARGET_DIR/"

if [ ! -f "$TARGET_DIR/index.html" ]; then
  echo "Health check failed: index.html missing"
  exit 1
fi

echo "Switching traffic to $TARGET_COLOR..."
sudo ln -sfn "$TARGET_DIR" "$ACTIVE_LINK"
sudo systemctl reload nginx

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$HEALTH_URL")
if [ "$HTTP_CODE" != "200" ]; then
  echo "Health check failed after switch — rolling back"
  exit 1
fi

echo "Deployment successful"
