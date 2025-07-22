#!/bin/bash

crontab -l 2>/dev/null > temp_cron || true

cat <<EOF >> temp_cron
# Take a weather measurement every 5 minutes
*/5 * * * * /usr/bin/python3 /home/madlab/dorval-weather/weather_station.py

# Upload weather measurements to dropbox every 30 minutes.
*/30 * * * * bash /home/madlab/dorval-weather/upload-to-dropbox.sh
EOF

crontab temp_cron
rm temp_cron

echo "Crontab installed."
