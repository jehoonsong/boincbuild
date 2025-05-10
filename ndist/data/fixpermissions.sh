#!/bin/bash

PROJECT_DIR="/home/boincadm/project"
DOWNLOAD_DIR="$PROJECT_DIR/download"

USER="boincadm"
GROUP="boincadm"

echo "Fixing permissions in: $DOWNLOAD_DIR"
echo "Setting owner to: $USER:$GROUP"

chown -R "$USER:$GROUP" "$DOWNLOAD_DIR"

find "$DOWNLOAD_DIR" -type d -exec chmod 755 {} \;

find "$DOWNLOAD_DIR" -type f -exec chmod 644 {} \;

echo "Permissions fixed."
