#!/bin/bash

#os check
os_search=$(lsb_release -ar 2>/dev/null | grep -i 'ID' | cut -s -f2)
if [ 1 != 1 ]; then
	os_status=1
	whiptail --msgbox 'OS not recognized, exiting in 5 secs' 20 60
	sleep 5
	exit
else
	os_status=0
fi

#sudo check
if [ 'whoami' == 'root' ]; then
    echo '[ERROR]: This install script requires sudo!'
    exit
fi

#setup
key_word_apt='sudo apt install'
key_rem='sudo apt remove'
key_word_pip='sudo pip install'
git_key='sudo git clone'
grub_file='/etc/default/grub'
mkdir /home/$USER/MyGit
sudo apt update -y && sleep 1 && sudo apt dist-upgrade && sleep 1
sudo apt autoremove -y && sleep 1 && sudo apt autoclean -y && sleep 1

pcspkr_check=$(lsmod | grep -i "pcspkr")
#pcspkr elimination
if whiptail --yesno 'Eliminate pcspkr?' 20 60; then
	if [ -n $pcspkr_check ]; then
		echo "pcspkr is not here, do not need to remove it"
	else 
		sudo rmmod pcspkr
	fi
fi

# implement touchpad support for i2c over hid
if whiptail --yesno 'implement touchpad support for i2c over hid? *WARNING, ONLY USE IF NECESSARY*' 20 60; then
        if [[ $os_status == 1 ]]; then
		echo "*Linux distribution for "i2c over hid" is not supported*"
        else
		grub_default_replace='GRUB_CMDLINE_LINUX_DEFAULT="quiet pci=nocrs"'
		grub_default_search=$(cat $grub_file | grep GRUB_CMDLINE_LINUX_DEFAULT)
		sed -i "s/$grub_default_search/$grub_default_replace/" $grub_file
		sleep 3
		sudo grub-mkconfig -o /boot/grub/grub.cfg
	fi
fi

#Hacking Tools
if whiptail --yesno 'Install Hacking Tools?' 20 60; then
	sudo apt install pip
	for i in catt snitch git-dumper
	do 
		$key_word_pip $i
		sleep 1
	done

	#Apt tools
	tools=( hydra lynis sherlock sucrack wireshark telnet filezilla sublist3r exploitdb exploitdb-bin-sploits aircrack-ng smbclient redis anonsurf anonsurf-gtk python3-shodan seclists sqlmap nikto kayak macchanger crunch burpsuite arp-scan git gobuster dirbuster wordlists theharvester metasploit-framework rfkill netcat docker.io exiftool smbmap fcrackzip evil-winrm ffuf )
	for terra in "${tools[@]}"
	do
		if [[ "$terra" == "docker.io" ]]; then
                	if [[ $os_status == 1 ]]; then
                        	echo "*Linux distribution for "docker.io" is not supported*"
                	else
                        	$key_word_apt docker.io -y
                	fi
		else
			$key_word_apt $terra -y 2>/dev/null
        	fi
	done
fi

#Generic/Security Bluetooth Programs
for z in spooftooph 
do
	$key_word_apt $t -y
	sleep 1
done

#checkra1n
echo 'deb https://assets.checkra.in/debian /' | sudo tee /etc/apt/sources.list.d/checkra1n.list
sudo apt-key adv --fetch-keys https://assets.checkra.in/debian/archive.key
sudo apt-get update && sleep 1
sudo apt-get install checkra1n -y

#Git Based Installs
gittool=( 'https://github.com/twintproject/twint.git' 'https://github.com/jaykali/maskphish.git' 'https://github.com/ASHWIN990/ADB-Toolkit' )
for p in "${gittool[@]}"
do
	cd /home/$USER/MyGit
	sudo git clone $p
	sleep 1
	if [ $p == $gittool ]; then
		cd twint
		pip3 install . -r requirements.txt
	fi
done

#Generic utilities
if whiptail --yesno 'Install General Utilities?' 20 60; then
	for T in mate-calc libreoffice xinput 
	do
		$key_word_apt $T -y
	done
fi

#Hardening
$key_word_apt ufw -y && sleep 3
VER=$(uname -a | grep "WSL")
if [ -n $VER ]; then
	sudo ufw allow 80
	sudo ufw allow 8080
	sudo ufw allow 5353
	sudo ufw enable
else 
	echo '''
	-----------------------------------------------
	*Not enabling UFW, would break VNC*"
	-----------------------------------------------
	'''
fi

$key_word_apt unattended-updates
dpkg-reconfigure --priority=low unattended-updates

if [ -n /etc/ssh/ssh_config ]; then
	echo "[ERROR] SSH config file not found"
else
	rp='AddressFamily inet' # only permit ipv4 and not ipv6 connections
	srch=$(cat /etc/ssh/ssh_config | grep AddressFamily)
	sed -i "s/$srch/$rp/" /etc/ssh/ssh_config
fi

#--------------------------------------------------------------
rmtools=( xboard nvim geany terminator xvkbd onboard dasher vlc qbittorrent onionshare mate-color-select remmina vokoscreenNG xterm uxterm xsane quodlibet )
for rmterra in "${rmtools[@]}"
do
    $key_rem $rmterra -y
done
sudo apt autoremove && sudo apt autoclean
