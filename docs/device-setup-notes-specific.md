Device Setup from regular Raspbian distribution
===============================================

# Configure Raspberry Pi

In this part you will get your Raspberry Pi 3 up and running.

1. Open the box and assemble Raspberry Pi 3
2. Install predefined Raspbery Pi 3 SDcard into device.
    Note: If there is no predefined SDcard. Flash a new SDcard with Raspbian pixel
    More info at https://www.raspberrypi.org/documentation/installation/installing-images/
3. Connect USB mouse and keyboard to Raspberry Pi 
4. Connect HDMI monitor with HDMI cable to the unit. 
5. Connect Raspberry to internet via ethernet.
6. Power the Unit with USB 
7. Install Raspberry
8. default user "pi" default password "raspberry" https://www.raspberrypi.org/documentation/linux/usage/users.md
    Note: It is good to confirm internet connectivity at this point to avoid future problems.

# Update and ready Raspberry Pi

In the following part you will update your Raspberry and ready it for the use as net emulator 

Update your Raspberry with following commands:

    sudo apt-get update

Optional:

    sudo apt-get upgrade

    Note: Install process will prompt you to select yes/no. Do it by typing y or n and pressing enter in the terminal.   
    Note: sudo apt-get upgrade takes quite a long time and may not be needed

Install dnsmasq and hostapd:

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


# Install NetEmu

1. From the Raspberry's browser go to https://github.com/OutSystems/netemu
    Note: If you are running headless you will probably need to do something differently to get the master.zip 

2. Download master zip
    Note: Following instructions may also be run from terminal with appropriate commands.

3. Extract the contents of zip file to a folder in /home/pi/ using the pixels GUI
	Example: /home/pi/netemu-install

4. Execute script "install-netemu.sh" in terminal from the master folder by double clicking.
   The script asks you for a name for the device and a password. Name should be a integer (number) and password a string
   (text/numbers) from 8 to 64 characters.
  
  	Note: The script will name your device netemuX where X is the integer (number) of your choice
	Note: Setting the name and password automatically has had some issues. This can be done manually later on and does not matter at 	 this point.
	
5. Raspberry will reboot automatically


# Open Wlan to users and configure rest of the files

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
    Note: Unlike in the script the ssid should be set as you want it to be shown in the wireless networks. (Setting it only as integer       means it will be only that)
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


Replace /etc/rc.local with rc.local file from conf-files folder
    


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

