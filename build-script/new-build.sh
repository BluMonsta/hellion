#Build Script

#Copy and then change default Kali SSH Keys - For protection from reverse hack attacks
cd /etc/ssh/
mkdir default_kali_keys
mv ssh_host_* default_kali_keys/
dpkg-reconfigure openssh-server
cd /

#Change Hostname just to be clear
#mv /etc/hostname /etc/hostname_orig
#> /etc/hostname
#echo "PenTestMachine" >/etc/hostname

#Uncomment the below if needed
#Change DNS Servers
#mv /etc/resolv.conf /etc/resolv_orig.conf
#> /etc/resolv.conf
#echo "nameserver 8.8.8.8" > /etc/resolv.conf
#echo "nameserver 8.8.4.4" >> /etc/resolv.conf

#Install random things
apt-get update
apt-get -y -qq install htop
apt-get -y -qq install reaver
apt-get -y -qq install macchanger
apt-get -y -qq install multimon-ng
apt-get -y -qq install rtl-sdr
apt-get -y -qq install tmux
apt-get -y -qq install hostapd-wpe
apt-get -y -qq install seclists
apt-get  -y qq install exiftool
cd /
cd root
git clone https://github.com/entropy1337/infernal-twin.git
#apt-get -y -qq upgrade
#apt-get autoclean
