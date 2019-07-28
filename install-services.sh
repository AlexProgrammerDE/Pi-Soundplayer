#!/bin/sh

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
	else
	clear
	echo "Pimusic Installation"
	echo ""
	echo "Preparing the System for Installation"
	echo ""
	echo "Adding needed Keys."
	# Spotify Key
	curl -sSL https://dtcooper.github.io/raspotify/key.asc | sudo apt-key add -v -
	echo 'deb https://dtcooper.github.io/raspotify raspotify main' | sudo tee /etc/apt/sources.list.d/raspotify.list
	
	# Mopidy Key
	wget -q -O - https://apt.mopidy.com/mopidy.gpg | sudo apt-key add -
	sudo wget -q -O /etc/apt/sources.list.d/mopidy.list https://apt.mopidy.com/stretch.list
	
	# Get updates
	echo "Updating System"
	echo ""
	sudo apt-get update
	sudo apt-get -y upgrade
	sudo apt -y autoremove
	# Install needed packages 
	echo "Getting needed Packages"
	echo ""
	sudo apt-get -y install wget gstreamer1.0-plugins-bad gstreamer1.0-tools gstreamer1.0-plugins-good gstreamer1.0-plugins-ugly gir1.2-gstreamer-1.0 gir1.2-gst-plugins-base-1.0 python-gst-1.0 python-dev python-pip curl alsa-base alsa-utils bluealsa bluez bluez-firmware python-gobject python-dbus mpg123 autotools-dev apt-transport-https dh-autoreconf git xmltoman autoconf automake libtool libpopt-dev libconfig-dev libasound2-dev avahi-daemon libavahi-client-dev libssl-dev libsoxr-dev

	# Making directory for data.
	mkdir service_data
	cd service_data
	echo ""
	echo "Installing"
	echo ""
	# Install package
	echo "Installing Spotify Support"
	echo ""
	sudo apt-get -y install raspotify

	# Script for Airplay
	echo ""
	echo "Installing Airplay Support"
	echo ""
	git clone https://github.com/mikebrady/shairport-sync.git
	cd shairport-sync
	echo ""
	echo "Wait please. This can take some time."
	echo ""
	autoreconf -fi
	./configure --sysconfdir=/etc --with-alsa --with-soxr --with-avahi --with-ssl=openssl --with-systemd
	make
	sudo make install
	systemctl enable shairport-sync
	systemctl start shairport-sync

	# Mopidy script 
	echo ""
	echo "Installing Mopidy Support"
	echo ""
	sudo apt-get -y install mopidy
	sudo systemctl enable mopidy
	sudo systemctl start mopidy
	# Mopidy Spotify
	sudo apt-get install -y mopidy-spotify
	
	# Mopidy Soundcloud
	sudo apt-get install mopidy-soundcloud
	
	# Mopidy Scrobbler
	pip install Mopidy-Scrobbler
	
	# Mopidy Tunein
	pip install Mopidy-TuneIn
	
	# Bluetooth script
	echo ""
	echo "Installing Bluetooth Support"
	echo ""
	cd ..
	git clone https://github.com/AlexProgrammerDE/rpi-bluetooth-audio-player.git
	cd rpi-bluetooth-audio-player
	export DBUS_SYSTEM_BUS_ADDRESS=unix:path=/run/dbus/system_bus_socket

	# Copy sounds
	echo ""
	echo "copying files"
	echo ""
	cp -r ./bluetooth-player/sounds/ /usr/src/sounds/

	# Setup udev rules - this lets us play the connect/disconnect sound
	# and also turn off discover/pairing when a client is connected
	cp -r ./bluetooth-player/bluetooth-udev /usr/src/
	chmod +x /usr/src/bluetooth-udev
	cp -r ./bluetooth-player/udev-rules/ /etc/udev/rules.d/

	# Bluetooth-agent handles the auth of devices
	cp -r ./bluetooth-player/bluetooth-agent /usr/src/
	chmod +x /usr/src/bluetooth-agent

	cp -r ./bluetooth-player/start.sh /usr/src/
	chmod +x /usr/src/start.sh
	
	echo ""
	echo "installing bluetooth-player service"
	echo ""
	sudo ln -sf /usr/src/start.sh /usr/local/bin/start_bt_player
	cp ./bluetooth-player/bluetooth-player.service /etc/systemd/system/
	echo""
	echo "done !!!" 
	echo ""
	echo "Starting Bluetooth Support"
	echo ""
	systemctl start bluetooth-player.service

fi
