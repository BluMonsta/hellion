#!/bin/bash
#project         Hellion (Active Info Gathering)
#author:        BluM0ns7a
#created:       August 2016 / Ongoing
#==============================================================================

echo -n "What Host or Range to use eg 172.16.10.2 OR 10.1.1.0/24 OR 10.1.1.1-100 "
read -e TARGET

#Menu options
options[0]="Host Discovery - Generate Live Hosts List"
options[1]="Port Discovery - Most Common Ports - Generate Protocol Specifics"
options[2]="Port Discovery - Full Port Scans (UDP is very slow)"
options[3]="Print TCP\UDP Ports - From Full Scan"
options[4]="Detect Service Version"
options[5]="Operating System Scan"
options[6]="Scan Target Web Based Enumeration (Use IP at this stage)"
options[7]="Scan Target SNMP + SMTP (Use IP at this stage)"
options[8]="Scan Target NetBIOS"

#Actions to take based on selection
function ACTIONS {
    
	
	if [[ ${choices[0]} ]]; then
        #Option 1 selected
	nmap -sn -T4 -oG Discovery.txt $TARGET
	grep "Status: Up" Discovery.txt | cut -f 2 -d ' ' > LiveHosts.txt
	fi
    	
	if [[ ${choices[1]} ]]; then
        #Option 2 selected
		nmap -sS -T4 -Pn --top-ports 3674 -oG 3674 -iL LiveHosts.txt
		nmap -sS -T4 -Pn -oG TopTCP -iL LiveHosts.txt
		mkdir protocol-specific
		mkdir protocol-enum
		grep /open/tcp//domain TopTCP | cut -d " " -f 2 > protocol-specific/dns-hosts.txt
		grep /open/tcp//http TopTCP | cut -d " " -f 2  > protocol-specific/web-hosts.txt
		grep /open/tcp//ssl TopTCP | cut -d " " -f 2  > protocol-specific/web-hosts-ssl.txt
		grep /open/tcp//microsoft-ds TopTCP | cut -d " " -f 2 > protocol-specific/smb-hosts.txt
		grep /open/tcp//ftp TopTCP | cut -d " " -f 2  > protocol-specific/ftp-hosts.txt
		grep /open/tcp//telnet TopTCP | cut -d " " -f 2  > protocol-specific/telnet-hosts.txt
		grep /open/tcp//smtp TopTCP | cut -d " " -f 2  > protocol-specific/smtp-hosts.txt
		grep /open/tcp//snmp TopTCP | cut -d " " -f 2  > protocol-specific/snmp-hosts.txt
		grep /open/tcp//ms-wbt-server TopTCP | cut -d " " -f 2  > protocol-specific/rdp-hosts.txt
		grep /open/tcp//pop3 TopTCP | cut -d " " -f 2  > protocol-specific/pop3-hosts.txt
		grep /open/tcp//imap TopTCP | cut -d " " -f 2  > protocol-specific/imap-hosts.txt
		grep /open/tcp//netbios-ssn TopTCP | cut -d " " -f 2  > protocol-specific/netbios-hosts.txt
		grep /open/tcp//ssh TopTCP | cut -d " " -f 2  > protocol-specific/ssh-hosts.txt
		grep /open/tcp//mysql TopTCP | cut -d " " -f 2  > protocol-specific/mysql-hosts.txt
		grep /open/tcp//vnc TopTCP | cut -d " " -f 2  > protocol-specific/vnc-hosts.txt
		nmap -sU -T4 -Pn -oN TopUDP -iL LiveHosts.txt
    fi
    
	if [[ ${choices[2]} ]]; then
        #Option 3 selected
		nmap -sS -T4 -Pn -p 0-65535 -oN FullTCP -iL LiveHosts.txt
		nmap -sU -T4 -Pn -p 0-65535 -oN FullUDP -iL LiveHosts.txt
    fi
    
	
	if [[ ${choices[3]} ]]; then
        #Option 4 selected
		grep "open" FullTCP|cut -f 1 -d ' ' | sort -nu | cut -f 1 -d '/' |xargs | sed 's/ /,/g'|awk '{print "T:"$0}'
		grep "open" FullUDP|cut -f 1 -d ' ' | sort -nu | cut -f 1 -d '/' |xargs | sed 's/ /,/g'|awk '{print "U:"$0}'
    fi
	
	
	if [[ ${choices[4]} ]]; then
        #Option 5 selected
		nmap -sV -T4 -Pn -oG ServiceDetect -iL LiveHosts.txt
    fi
	
	
	if [[ ${choices[5]} ]]; then
        #Option 6 selected
		nmap -O -T4 -Pn -oG OSDetect -iL LiveHosts.txt
    fi
	
	if [[ ${choices[6]} ]]; then
        #Option 7 selected
	nikto -h $TARGET | tee protocol-enum/nikto.txt
	dirb http://$TARGET/ | tee protocol-enum/dirb.txt
	gobuster -u http://$TARGET/ -w /usr/share/seclists/Discovery/Web_Content/common.txt -s '200,204,301,302,307,403,500' -e | tee protocol-enum/gobuster-common.txt
	gobuster -u http://$TARGET/ -w /usr/share/seclists/Discovery/Web_Content/big.txt -s '200,204,301,302,307,403,500' -e | tee protocol-enum/gobuster-big.txt
	uniscan -u http://$TARGET/ -qdgj | tee protocol-enum/uniscan.txt
	wfuzz -c -z file,/usr/share/wfuzz/wordlist/general/big.txt --hc 404 http://$TARGET/ | tee protocol-enum/wfuzz.txt
	fimap -u "http://$TARGET/" | tee protocol-enum/fimap.txt
    fi
    
	if [[ ${choices[7]} ]]; then
        #Option 8 selected
	onesixtyone $TARGET | tee protocol-enum/onesixtyone.txt
	snmpwalk -c public -v1 $TARGET | tee protocol-enum/snmpwalk-v1.txt
	snmpwalk -c public -v2c $TARGET | tee protocol-enum/snmpwalk-v2c.txt
    smtp-user-enum -M VRFY -U /usr/share/seclists/Usernames/top_shortlist.txt -t $TARGET | tee protocol-enum/smtp-user-enum.txt
	fi
	
		
	if [[ ${choices[8]} ]]; then
        #Option 9 selected
	nbtscan -f protocol-specific/netbios-hosts.txt | tee protocol-enum/nbtscan.txt
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
    echo "TARGET/Range in scope: " $TARGET
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
