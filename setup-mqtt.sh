#!/bin/bash

sudo apt install -y mosquitto mosquitto-clients
sudo service mosquitto status
sudo systemctl enable mosquitto
sudo systemctl start mosquitto
sudo service mosquitto status
sudo cpan install Net::MQTT:Simple Net::MQTT:Constants
