Configure Raspberry Pi
In this part you will get your Raspberry Pi 3 up and running.

Open the box and assemble Raspberry Pi 3
Install predefined Raspbery Pi 3 SDcard into device.
Note: If there is no predefined SDcard. Flash a new SDcard with Raspbian pixel
More info at https://www.raspberrypi.org/documentation/installation/installing-images/
Connect USB mouse and keyboard to Raspberry Pi 
Connect HDMI monitor with HDMI cable to the unit. 
Connect Raspberry to internet via ethernet.
Power the Unit with USB 
Install Raspberry
default user "pi" default password "raspberry" https://www.raspberrypi.org/documentation/linux/usage/users.md
Note: It is good to confirm internet connectivity at this point to avoid future problems.

Update and ready Raspberry Pi
In the following part you will update your Raspberry and ready it for the use as net emulator 

Update your Raspberry with following commands:


sudo apt-get update
Optional:

sudo apt-get upgrade


Note: Install process will prompt you to select yes/no. Do it by typing y or n and pressing enter in the terminal.   
Note: sudo apt-get upgrade takes quite a long time and may not be needed

Install dnsmasq and hostapd

sudo apt-get install dnsmasq hostapd


Update NodeJs repository:

curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
Note: In the url /setup_10.x the number 10 represents the version of nodejs to be installed. Please check the latest version.


After NodeJs repository is updated. Update the NodeJs itself:

sudo apt-get install nodejs


Also update node package manager:

sudo apt-get install npm
Note: There maybe some errors of missing depencies. Shouldn't matter.

Install needed nodejs packages:

npm install express
npm install swig


Enable ssh

sudo systemctl enable ssh
sudo systemctl start ssh
Note: If you are running headless, more info at https://www.raspberrypi.org/documentation/remote-access/ssh/


Install NetEmu


From the Raspberry's browser go to https://github.com/OutSystems/netemu
Note: If you are running headless you will probably need to do something differently to get the master.zip 
Download master zip
Note: Following instructions may also be run from terminal with appropriate commands.
Extract the contents of zip file to a folder in /home/pi/ using the pixels GUI
Example: /home/pi/netemu-install
Execute script "install-netemu.sh" in terminal from the master folder by double clicking.
The script asks you for a name for the device and a password. Name should be a integer (number) and password a string (text/numbers) from 8 to 64 characters.
Note: The script will name your device netemuX where X is the integer (number) of your choice
Note: Setting the name and password automatically has had some issues. This can be done manually later on and does not matter at this point.
Raspberry will reboot automatically

Open Wlan to users and configure rest of the files
Next you will enable wlan access point and IP-forwarding by configuring some files.



Open hostapd.conf with

sudo nano /etc/hostapd/hostapd.conf
Write/copy to hostapd.conf the following

interface=wlan0
driver=nl80211
ssid=NETEMU-PLACEHOLDER
hw_mode=g
channel=7
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=SECRET1234
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
Note: Here you can set up your ssid and password.

Set the fields: "ssid" and "wpa_passphrase" to your liking. 
Note: Unlike in the script the ssid should be set as you want it to be shown in the wireless networks. (Setting it only as integer means it will be only that)
Note: Password should be 8-64 characters

Tell the hostapd where to find the .conf file.
Open following file:

sudo nano /etc/default/hostapd
In hostapd replace the following line:

#DAEMON_CONF=""
With:

DAEMON_CONF="/etc/hostapd/hostapd.conf"
Note: This line should be only uncommented line in the file.


Open dhcpcd.conf:

sudo nano /etc/dhcpcd.conf
In the very end of the file write/copy the following:

interface wlan0
	static ip_address=10.201.0.1
denyinterfaces wlan0
Note: IP-address may be set differently e.g 192.168.4.1 but it must be configured elsewhere as well.


Set up dnsmasq.conf
dnsmasq.conf contains a lot of data not needed in this operation. It can be just overwritten but it is recommended to save a copy of the original file.

Move the original file:

sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
Create and edit new dnsmasq.conf file:

sudo nano /etc/dnsmasq.conf
Write/copy into the file:

interface=wlan0     
	dhcp-range=10.201.0.2,10.201.0.99,255.255.255.0,24h
	#addn-hosts=/etc/dnsmasq.hosts


Open rc.local

sudo nano /etc/rc.local
Set up the file so it looks like following:

#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.

# Print the IP address
_IP=$(hostname -I) || true
if [ "$_IP" ]; then
  printf "My IP address is %s\n" "$_IP"
fi

echo 1 > /proc/sys/net/ipv4/ip_forward

cd /home/pi/netemu/tc-server
nohup setsid node app.js &

exit 0


Open sysctl.conf

sudo nano /etc/sysctl.conf
Find and uncomment line:

#net.ipv4.ip_forward=1


Reboot your device. It should now be visible to scans from wireless devices and it should be possible to connect to.
Connection to internet will not yet work though. 

Set iptables:

sudo iptables -t nat -A  POSTROUTING -o eth0 -j MASQUERADE
Note: Everything should now be working as expected if the device is not rebooted.


To make iptable configuration last over reboot. Make them persistent:

sudo apt-get install iptables-persistent
Installation will ask you to save iptables for ipv4 and ipv6. Select yes to both.
Now if you reboot the device should work as intended.
 

Additional details: Setting up LCD touch display
Install LCD driver
Guide: https://www.waveshare.com/wiki/3.5inch_RPi_LCD_(B)

Change resolution to 1920x1080 after LCD driver install.
This is optional. Recommended if you are using external monitor with higher resolution than the LCD. 
Better UI in 5. step is tested only on 1920x1080 resolution but should be responsive. 

Colors?
For some reason colors on the LCD are inverted. No solution at the moment unfortunately.

To get rid of wasted pixels on screen run:

sudo nano /boot/config.txt
and uncomment line:

disable_overscan=1
Note: It will take effect on reboot


Better UI

To make the UI of the network emulator more suitable for small lower resolution display.
Replace /home/pi/netemu/tc-server/index.html with:

<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
<title>Network Emulator</title>
<style>
body {background-color: white;}
h1 {color: info;}
p {color: red;}

.btn{
margin-bottom: 10%;
width: 60%;
padding-bottom:2.5vw;
padding-top:2.5vw;


}
.btn_font{
font-size: 3vw;
}

.h2_font{
font-size: 3.3vw;
}

.h1_font{
font-size: 5vw;
}

.pre_font{
font-size: 4vw;
}
</style>
</head>
<body>
<div align="center" style="width:100%">
<div style="width:85%;">
<div align="center">
<h1 class="h1_font">Network Emulator</h1>
</div>



<div style="width:30%; float:left;">
<h2 class="h2_font" >Current state </h2>
<pre class="pre_font"><code>{{ status }}</code></pre>
<h2 class="h2_font" >Last status</h2>
<pre class="pre_font">{{ lastOut }}</pre>
</div>


<div style="width:65%; float:right;">
<h2 class="h2_font">Set another</h2>

<div style="width:50%; float:left;">
<div><a href="/setnetwork/wifi"type="button" class="btn btn-primary"><span class="btn_font">WIFI</span></a></div>
<div><a href="/setnetwork/4g" type="button" class="btn btn-primary" ><span class="btn_font">4G</span></a></div>
<div><a href="/setnetwork/3g"type="button" class="btn btn-primary" ><span class="btn_font">3G</span></a></div>
</div>

<div style="width:50%; float:right;">

<div><a href="/setnetwork/2g"type="button" class="btn btn-primary" ><span class="btn_font">2G</span></a></div>
<div><a href="/setnetwork/gprs" type="button" class="btn btn-primary"><span class="btn_font">GPRS</span></a></div>
</div>
</div>
</div>
</div>

Note: This may cause issues in older browsers. <IE9


Chromium launch on boot
https://raspberrypi.stackexchange.com/questions/69204/open-chromium-full-screen-on-start-up
Note: To get out of KIOSK mode press ctrl+w
