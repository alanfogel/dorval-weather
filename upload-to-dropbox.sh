#!/bin/bash

PICTURES_DIR=~/dendro-pi-main/pictures
LOG_FILE=~/dendro-pi-main/logs/error_log.txt
UPLOAD_LOG=~/dendro-pi-main/logs/upload_error_log.txt
DROPBOX_PATH="/Dorval-Weather/"

# --- Upload pictures ---
cd ~/dendro-pi-main/Dropbox-Uploader
./dropbox_uploader.sh upload ~/dendro-pi-main/pictures/* "$DROPBOX_PATH" | grep "file exists with the same hash" > already_uploaded.txt

while IFS= read -r line; do
  FILENAME=$(echo "$line" | cut -d'"' -f 2)
  rm "$FILENAME"
done < already_uploaded.txt

# --- Attempt to upload error log if it exists and is not empty ---
if [ -s "$LOG_FILE" ]; then
  ./dropbox_uploader.sh upload "$LOG_FILE" "$DROPBOX_PATH" || {
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$TIMESTAMP] Failed to upload error_log.txt" >> "$UPLOAD_LOG"
  }
fi