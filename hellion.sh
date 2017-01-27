#!/bin/bash
#project         Hellion (Active Info Gathering)
#author:        BluM0ns7a
#created:       August 2016 / Ongoing
#==============================================================================

echo -n "What Subnet or IP Range to use eg 10.1.1.0/24 or 10.1.1.1-100 "
read -e SUBNET

#Menu options
options[0]="Scan Subnet for Active Hosts"
options[1]="Scan Alive Hosts Common Ports"
options[2]="Scan Alive Hosts All Ports **Intensive**"
options[3]="OS Recon Alive Hosts"
options[4]="TBC"
options[5]="Obtain Web Headers from Web Servers"

#Actions to take based on selection
function ACTIONS {
    if [[ ${choices[0]} ]]; then
        #Option 1 selected
        mkdir Network-Recon
	nmap -sn -T4 $SUBNET -oG Network-Recon/network-sweep.txt
	grep Up Network-Recon/network-sweep.txt | cut -d " " -f 2 > Network-Recon/alive-hosts.txt
	#nmap -sU -r $SUBNET -oG Network-Recon/network-sweep-udp.txt
	#grep Up Network-Recon/network-sweep-udp.txt | cut -d " " -f 2 > Network-Recon/alive-hosts-udp.txt
    fi
    if [[ ${choices[1]} ]]; then
        #Option 2 selected
	#nmap -sU -T4 -Pn -oN Network-Recon/TopUDP.txt -iL Network-Recon/alive-hosts-udp.txt
	nmap -sS -T4 -Pn -oG Network-Recon/TopTCP.txt -iL Network-Recon/alive-hosts.txt
	nmap -sS -T4 -Pn --top-ports 3674 -oG Network-Recon/3674-top-ports.txt -iL Network-Recon/alive-hosts.txt
	mkdir Protocol-Specific
	grep /open/tcp//domain Network-Recon/TopTCP.txt | cut -d " " -f 2 > Protocol-Specific/dns-hosts.txt
	grep /open/tcp//http Network-Recon/TopTCP.txt | cut -d " " -f 2  > Protocol-Specific/web-hosts.txt
	grep /open/tcp//ssl Network-Recon/TopTCP.txt | cut -d " " -f 2  > Protocol-Specific/web-hosts-ssl.txt
	grep /open/tcp//microsoft-ds Network-Recon/TopTCP.txt | cut -d " " -f 2 > Protocol-Specific/smb-hosts.txt
	grep /open/tcp//ftp Network-Recon/TopTCP.txt | cut -d " " -f 2  > Protocol-Specific/ftp-hosts.txt
	grep /open/tcp//telnet Network-Recon/TopTCP.txt | cut -d " " -f 2  > Protocol-Specific/telnet-hosts.txt
	grep /open/tcp//smtp Network-Recon/TopTCP.txt | cut -d " " -f 2  > Protocol-Specific/smtp-hosts.txt
	grep /open/tcp//snmp Network-Recon/TopTCP.txt | cut -d " " -f 2  > Protocol-Specific/snmp-hosts.txt
	grep /open/tcp//ms-wbt-server Network-Recon/TopTCP.txt | cut -d " " -f 2  > Protocol-Specific/rdp-hosts.txt
	grep /open/tcp//pop3 Network-Recon/TopTCP.txt | cut -d " " -f 2  > Protocol-Specific/pop3-hosts.txt
	grep /open/tcp//imap Network-Recon/TopTCP.txt | cut -d " " -f 2  > Protocol-Specific/imap-hosts.txt
    fi
    if [[ ${choices[2]} ]]; then
        #Option 3 selected
	nmap -sS -T4 -Pn -p 0-65535 -oN Network-Recon/FullTCP.txt -iL Network-Recon/alive-hosts.txt
	nmap -sU -T4 -Pn -p 0-65535 -oN Network-Recon/FullUDP.txt -iL Network-Recon/alive-hosts-udp.txt
    fi
    if [[ ${choices[3]} ]]; then
        #Option 4 selected
	mkdir OSRecon
	nmap -O -T4 -Pn -oG OSRecon/OSDetect.txt -iL Network-Recon/alive-hosts.txt
	nmap -p- -sS -A $SUBNET > OSRecon/service-fingerprinting.txt
    fi
    if [[ ${choices[4]} ]]; then
        #Option 5 selected
	mk
        nbtscan -f smb-hosts.txt > hostnames.txt
    fi
    if [[ ${choices[5]} ]]; then
        #Option 6 selected
	nohup cat web-hosts.txt | xargs -n4 curl -L &>web-headers.txt
        nohup cat web-hosts-ssl.txt | xargs -n4 curl -L &>web-headers-ssl.txt
    fi
}

#Variables
ERROR=" "

#Clear screen for menu
clear

#Menu function
function MENU {
    echo "**** Hellion Active Enum Project ****"
    echo " "
    echo "Subnet/Range in scope: " $SUBNET
    echo " "
    for NUM in ${!options[@]}; do
        echo "[""${choices[NUM]:- }""]" $(( NUM+1 ))") ${options[NUM]}"
    done
    echo "$ERROR"
}

#Menu loop
while MENU && read -e -p "Select the desired options using their number (again to uncheck, ENTER when done): " -n1 SELECTION && [[ -n "$SELECTION" ]]; do
    clear
    if [[ "$SELECTION" == *[[:digit:]]* && $SELECTION -ge 1 && $SELECTION -le ${#options[@]} ]]; then
        (( SELECTION-- ))
        if [[ "${choices[SELECTION]}" == "+" ]]; then
            choices[SELECTION]=""
        else
            choices[SELECTION]="+"
        fi
            ERROR=" "
    else
        ERROR="Invalid option: $SELECTION"
    fi
done

ACTIONS

