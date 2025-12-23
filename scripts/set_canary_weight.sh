#!/bin/bash
set -euo pipefail

BLUE_WEIGHT="${1:-90}"
GREEN_WEIGHT="${2:-10}"

CONF="/etc/nginx/conf.d/canary.conf"

# Update weights in-place
sudo sed -i \
  -e "s/server 127.0.0.1:9001 weight=[0-9]\\+;/server 127.0.0.1:9001 weight=${BLUE_WEIGHT};/" \
  -e "s/server 127.0.0.1:9002 weight=[0-9]\\+;/server 127.0.0.1:9002 weight=${GREEN_WEIGHT};/" \
  "$CONF"

sudo nginx -t
sudo systemctl reload nginx

echo "Weights updated: BLUE=${BLUE_WEIGHT}, GREEN=${GREEN_WEIGHT}"
