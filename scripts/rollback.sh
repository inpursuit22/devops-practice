#!/bin/bash
set -euo pipefail

ACTIVE_LINK="/usr/share/nginx/html"
BLUE_DIR="/var/www/blue"
GREEN_DIR="/var/www/green"

ACTIVE_TARGET="$(readlink -f "$ACTIVE_LINK" || true)"

if [ "$ACTIVE_TARGET" = "$BLUE_DIR" ]; then
  sudo ln -sfn "$GREEN_DIR" "$ACTIVE_LINK"
  echo "Rolled back to GREEN"
else
  sudo ln -sfn "$BLUE_DIR" "$ACTIVE_LINK"
  echo "Rolled back to BLUE"
fi

sudo systemctl reload nginx
