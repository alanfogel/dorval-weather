# 🌲 Raspberry Pi BME280 Sensor Setup Guide

This guide walks you through setting up a Raspberry Pi from scratch and configuring a BME280 temperature, humidity, and pressure sensor using I2C communication.

My other projects involving Raspberry Pi's:
- [Dendro-Pi-Main](https://github.com/alanfogel/dendro-pi-main)
- [Charge Controller](https://github.com/alanfogel/ChargeController)
- [Dendrometer Logger](https://github.com/alanfogel/dendro-logger)

The default behaviour of this system is to take measurements from the BME280 sensor every 5 minutes every day, and upload the data each night to a Dropbox folder.

## Prerequisites
- Raspberry Pi (any model with 40-pin GPIO header recommended)
- MicroSD card 
- BME280 sensor module
- Jumper wires (female-to-female)
- Computer with SD card reader
- Internet connection
---

## ⚙️ Initial Setup: Flashing the Pi SD Card

1. Insert SD card into your computer.
2. Download and open [Raspberry Pi Imager](https://www.raspberrypi.com/software/).
3. Configure with the following:
   - **Device**: Raspberry Pi Zero ***(Not Zero 2 W)***
   - **OS**: Raspberry Pi OS 32-bit (Bookworm)
   - **Storage**: Select Storage (Mass Storage Device USB Device)
   ### - Edit settings
   - **Hostname**: e.g., `Dorval-Weather`
   - **Username/Password** (To log into the Pi): `madlab` / `______`
   - **Wi-Fi SSID/Password**: `new_aspen_2022` / `___________`
   - **Country**: CA
   - **Enable SSH**: Use password authentication
4. Save
    - Apply OS Customization Settings: Yes

5. When done, insert the SD card into your Pi and power it up.

---

## 🔌 Connect & Configure the Raspberry Pi

1. Connect your laptop to the same Wi-Fi as the Pi.
2. Open terminal (or PowerShell) and SSH into your Pi:
   ```bash
   ssh madlab@Dorval-Weather.local # ssh username@{hostname}.local
   ```
   if cannot resolve the hostname, use the IP address:
   ```bash
   nslookup Dorval-Weather.local # to find the IP address
   ssh madlab@{IP_ADDRESS} # ssh username@{IP_ADDRESS}
   ```
3. Run:
    ```bash
    sudo raspi-config
    ```
    - Set timezone under Localization Options
    - Enable I2C (Interface Options → I2C → Yes)
    - Reboot the Pi
4. Connect the BME280 sensor to your Raspberry Pi:
- BME280 Pin	Raspberry Pi Pin
- VCC/VIN	3.3V (Pin 1)
- GND	Ground (Pin 6)
- SCL	GPIO 3 (SCL, Pin 5)
- SDA	GPIO 2 (SDA, Pin 3)

*Note: Some BME280 modules use 5V for VCC - check your specific module's requirements.*

## 📦 Installing dendro-pi Scripts

1. Clone the project:
```bash
git clone https://github.com/alanfogel/dorval-weather.git
cd dorval-weather
```
2. Update your system:
```bash
sudo apt update && sudo apt upgrade -y
```
3. Create & Activate virtual environment:
```
python3 -m venv venv
```
```bash
source venv/bin/activate
```
4. Install required packages:
```bash
pip3 install -r requirements.txt
```
4. Verify I2C detection:
```bash
sudo i2cdetect -y 1
```
You should see a device listed (typically 0x76 or 0x77)
If its different than 0x77 you'll need to edit ```weather_station.py``` to match.

## ☁️ Configure Dropbox Upload

1. In the root project directory ```~/dorval-weather/```:
```bash
git clone https://github.com/alanfogel/Dropbox-Uploader.git
cd Dropbox-Uploader
sudo chmod +x dropbox_uploader.sh
```
```bash
./dropbox_uploader.sh
```
- At the end of the output of the above command, it will ask for the “App key”
- Go to the Dropbox app developer url and login with your Dropbox account, a screen will appear having a “Create an app” button, and a list of Apps created with your account. Select “DendroPictures”
-	Under the settings tab - Scroll down and you will find the “App key” and “App secret”, note down them and return back to the terminal
-	In the terminal enter the codes when promted, (when you enter the “App secret”, then it will give you a link, visiting it, you will get the “Access code”), once all the information is provided you will link with your dropbox cloud.

2. Update upload-to-dropbox.sh:
```bash
cd ..
nano upload-to-dropbox.sh
```
Modify the variable declaration line (Replace `Dorval-Weather` with your Dropbox folder name):
```bash
DROPBOX_PATH="/Dorval-Weather/"
```

3. Ensure UNIX line endings:
```bash
dos2unix upload-to-dropbox.sh
```


## 🕓 Setup Crontab
1. Open crontab and save immediately:
```bash
crontab -e
```

2. Check if its empty:
```bash
crontab -l
```
3. If it's not empty, run:
```bash
crontab -r
```
4. Install scheduled jobs:
```bash
sh add_cron.sh
```
5. Confirm:
```bash
crontab -l
```
6. You can edit the crontab file to change the schedule (like staggering the uploads):
```bash
crontab -e
```

## ✅ Test Setup
```bash
# Take a Measurement
/home/madlab/dorval-weather/venv/bin/python /home/madlab/dorval-weather/weather_station.py
```

```bash
# Upload .csv to dropbox
cd ..
bash /home/madlab/dorval-weather/upload-to-dropbox.sh
```
- Check Dropbox for uploaded files.
