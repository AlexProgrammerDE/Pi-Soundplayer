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
	
	# Get updates
	clear
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
	clear
	echo "Installing"
	echo ""
	# Install package
	clear
	echo "Installing Spotify Support"
	echo ""
	sudo apt-get -y install raspotify

	# Script for Airplay
	clear
	echo "Installing Airplay Support"
	echo ""
	git clone https://github.com/mikebrady/shairport-sync.git
	cd shairport-sync
	clear
	echo "Wait please. This can take some time."
	echo ""
	autoreconf -fi
	./configure --sysconfdir=/etc --with-alsa --with-soxr --with-avahi --with-ssl=openssl --with-systemd
	make
	sudo make install
	systemctl enable shairport-sync
	systemctl start shairport-sync

	# Bluetooth script
	clear
	echo "Installing Bluetooth Support"
	echo ""
	cd ..
	git clone https://github.com/AlexProgrammerDE/rpi-bluetooth-audio-player.git
	cd rpi-bluetooth-audio-player
	sudo bash install.sh
	clear
fi
