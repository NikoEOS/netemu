#!/bin/bash

read -p "Name of this instance: " instance_name
read -s -p "WIFI password: " wifi_pass
echo

upper_instance=${instance_name^^}

echo netemu-$instance_name > /etc/hostname

sudo apt-get -y install dnsmasq hostapd git

curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -

sudo iptables -t nat -A POSTROUTING -j MASQUERADE
sudo apt-get -y install iptables-persistent 
sudo apt-get -y install nodejs
sudo apt-get -y npm

sudo systemctl enable ssh
sudo systemctl start ssh

# do the tar
tail -n+29 $0 | base64 -d | tar zx -C /

cp 

sed -i -e "s/<UPPERNAME>/$upper_instance/" -e "s/<WIFI_PASSWORD>/$wifi_pass/" /etc/hostapd/hostapd.conf
sed -i -e "s/<instance>/$instance_name/" /etc/dnsmasq.hosts

cd /home/pi/
git clone https://github.com/NikoEOS/netemu

cd Downloads/netemu-master/conf-files

sudo cp dhcpcd.conf /etc/dhcpcd.conf
sudo cp hostapd.conf /etc/hostapd/hostapd.conf
sudo cp hostapd /etc/default/hostapd
sudo cp dnsmasq.conf /etc/dnsmasq.conf
sudo cp rc.local /etc/rc.local

reboot
exit
# do not edit below
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
ODg4ODg4ODg4ODg4fG/4L0Nf+/IAUAAA
