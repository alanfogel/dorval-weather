#!/bin/bash

# Simple Dropbox Uploader for Weather Data with Day-Old Deletion
# ------------------------------------------------------------

# Configuration
WEATHER_DIR=~/weather_data
DROPBOX_DIR="/Dorval-Weather/"
LOG_FILE=~/weather_logs/upload_errors.txt
UPLOADER=~/Dropbox-Uploader/dropbox_uploader.sh

# Ensure directories exist
mkdir -p ~/weather_logs

# Get yesterday's date in YYYY-MM-DD format
YESTERDAY=$(date -d "yesterday" '+%Y-%m-%d')

# Log errors with timestamp
log_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Process each CSV file
for csv_file in "$WEATHER_DIR"/Dorval_Weather_*.csv; do
    if [ -f "$csv_file" ]; then
        # Extract date from filename (format: Dorval_Weather_YYYY-MM-DD.csv)
        file_date=$(basename "$csv_file" | cut -d'_' -f3 | cut -d'.' -f1)
        
        # Attempt upload
        if "$UPLOADER" upload "$csv_file" "$DROPBOX_DIR"; then
            # Only delete if file is from yesterday or earlier
            if [[ "$file_date" < "$YESTERDAY" || "$file_date" == "$YESTERDAY" ]]; then
                rm "$csv_file" || log_error "Failed to delete: $csv_file"
            fi
        else
            log_error "Upload failed: $csv_file"
        fi
    fi
done