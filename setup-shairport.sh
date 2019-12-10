#!/bin/sh

# Config /etc/shairport-sync.conf

red='\e[1;31m'
grn='\e[1;32m'
yel='\e[1;33m'
blu='\e[1;34m'
mag='\e[1;35m'
cyn='\e[1;36m'
end='\e[0m'

####echo "Text in ${red}red${end}, white, ${grn}green${end}, ${cyn}cyan${end}, ${yel}yellow${end}, ${mag}magenta${end} and ${blu}blue${end}."

echo "${yel}This script installs shairport-sync on this device.${end}"
read -p "Installing it the first time here? [y/N]: " firstTime
firstTime=${firstTime:-N}

echo "${grn}Current installed Version:${end} "
last=$(shairport-sync -V)
echo $last

read -p "$(echo $yel"Would you like go to development or master (more stable)? [d/M]: "$end)" channel
channel=${channel:-M}

if [ "$firstTime" = "y" ]; then
	sudo apt update
	sudo apt dist-upgrade -y
	sudo apt autoremove -y
	sudo apt install -y build-essential git xmltoman autoconf automake libtool \
    	libpopt-dev libconfig-dev libasound2-dev avahi-daemon libavahi-client-dev \
	libssl-dev libsoxr-dev
	git clone https://github.com/mikebrady/alac.git ~/
	git pull https://github.com/mikebrady/alac.git ~/
	cd ~/alac
	autoreconf -fi
	./configure
	make -j4
	sudo make install
	sudo ldconfig
	make clean
	git clone https://github.com/mikebrady/shairport-sync.git ~/
fi

#rm -r git shairport-sync/*
#sudo rm -r git shairport-sync/.*
#git pull https://github.com/mikebrady/shairport-sync.git ~/

cd ~/shairport-sync/
git stash
git stash drop
git pull

#sudo rm /etc/systemd/system/shairport-sync.service
#sudo rm /etc/init.d/shairport-sync

if [ "$channel" = "d" ]; then
#	cd ./shairport-sync
	#git fetch origin
	#git stash
#	git add --all
#	git reset --hard origin/development
	#git rm *
	#git clean -fd
#	git pull https://github.com/mikebrady/shairport-sync.git
	#git reset --hard origin/development
	git checkout development
	git rebase development
	#git pull -f

elif [ "$channel" = "M" ]; then
#	cd ./shairport-sync
	#git pull https://github.com/mikebrady/shairport-sync.git
	#git reset --hard origin/master
	git checkout master
	git rebase master
	#git pull -f
else
	echo "${red}Unknown parameter -> exit${end}"
	return
fi

autoreconf -fi
./configure --sysconfdir=/etc --with-alsa --with-avahi --with-ssl=openssl --with-metadata --with-soxr --with-systemd --with-convolution --with-apple-alac
make -j4

sudo systemctl stop shairport-sync
sudo rm $(which -a shairport-sync)
sudo rm /etc/systemd/system/shairport-sync.service
sudo rm /etc/init.d/shairport-sync

sudo make install
make clean
sudo systemctl enable shairport-sync
sudo systemctl start shairport-sync
sudo systemctl status shairport-sync
echo ""
echo "${yel}Config happens here:${end}"
echo "${yel}sudo nano /etc/shairport-sync.conf${end}"
echo "${grn}Now installed Version: ${end}"
update=$(shairport-sync -V)
echo $update
echo "${yel}Old version was $last ${end}"

if [ "$last" = "$update" ]; then
	echo "${red}Version number didn't changed.${end}"
elif [ -z "$update" ]; then
	echo "${red}Installation returned an error!${end}"
else
	echo "${grn}Sucessfully updated!${end}"
fi

exit 0
