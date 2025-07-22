import smbus2
import bme280
import time
from datetime import datetime
import csv
import os
from pathlib import Path

# Use absolute path with home directory expansion
LOG_DIR = os.path.expanduser("~/dorval-weather/weather_data")

# Sensor configuration
SENSOR_ADDRESS = 0x77

class BME280Logger:
    def __init__(self):
        self.bus = smbus2.SMBus(1)
        self.calibration_params = bme280.load_calibration_params(
            self.bus, SENSOR_ADDRESS)

        # Create log directory if it doesn't exist
        Path(LOG_DIR).mkdir(parents=True, exist_ok=True)

    def get_sensor_data(self):
        data = bme280.sample(self.bus, SENSOR_ADDRESS, self.calibration_params)
        return {
            'timestamp': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
            'temperature': round(data.temperature, 2),
            'pressure': round(data.pressure, 2),
            'humidity': round(data.humidity, 2)
        }

    def get_daily_filename(self):
        today = datetime.now().strftime('%Y-%m-%d')
        return f"{LOG_DIR}/Dorval_Weather_{today}.csv"

    def log_data(self):
        filename = self.get_daily_filename()
        data = self.get_sensor_data()
        
        # Check if file exists to determine if we need headers
        file_exists = os.path.isfile(filename)
        
        with open(filename, 'a', newline='') as csvfile:
            fieldnames = ['Timestamp', 'Temperature (°C)', 'Pressure (hPa)', 'Humidity (%)']
            writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
            
            if not file_exists:
                writer.writeheader()
            
            writer.writerow({
                'Timestamp': data['timestamp'],
                'Temperature (°C)': data['temperature'],
                'Pressure (hPa)': data['pressure'],
                'Humidity (%)': data['humidity']
            })

if __name__ == "__main__":
    logger = BME280Logger()
    logger.log_data()