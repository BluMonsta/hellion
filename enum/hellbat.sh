#!/bin/bash
#project         Hellion (Active Info Gathering)
#author:        BluM0ns7a
#created:       August 2016 / Ongoing
#==============================================================================

echo -n "What Host or Range to use eg 172.16.10.2 OR 10.1.1.0/24 OR 10.1.1.1-100 "
read -e TARGET

#Menu options
options[0]="The Harvester"
options[1]="Who Is"
#options[2]="Scan Target UDP Ports - Uncomment for All Ports"
#options[3]="Scan Target Web Based Enumeration"
#options[4]="Scan Target Web Based Attacks"
#options[5]="Scan Target Uniscan"
#options[6]="Scan Target SNMP"
#options[7]="Scan Target SMTP"

#Actions to take based on selection
function ACTIONS {
    if [[ ${choices[0]} ]]; then
        #Option 1 selected
	theharvester -d $TARGET -b google
	fi
    
	if [[ ${choices[1]} ]]; then
        #Option 2 selected
	whois $TARGET
	fi
    
	if [[ ${choices[2]} ]]; then
        #Option 3 selected
		nmap -Pn -A -sC -sU -T4 --top-ports 200 $TARGET | tee Network-Recon/3674-top-ports.txt
		#nmap -Pn -A -sC -sU -p 0-65535 | tee Network-Recon/FullUDP.txt
    fi
    
	if [[ ${choices[3]} ]]; then
        #Option 4 selected
		mkdir Web-Recon
	nikto -h $TARGET | tee Web-Recon/nikto.txt
	dirb http://$TARGET/ | tee Web-Recon/dirb.txt
	gobuster -u http://$TARGET/ -w /usr/share/seclists/Discovery/Web_Content/common.txt -s '200,204,301,302,307,403,500' -e | tee Web-Recon/gobuster-common.txt
	gobuster -u http://$TARGET/ -w /usr/share/seclists/Discovery/Web_Content/big.txt -s '200,204,301,302,307,403,500' -e | tee Web-Recon/gobuster-big.txt
    fi
    
	if [[ ${choices[4]} ]]; then
		#Option 5 selected
    wfuzz -c -z file,/usr/share/wfuzz/wordlist/general/big.txt --hc 404 http://$TARGET/ | tee Web-Recon/wfuzz.txt
	fimap -u "http://$TARGET/" | tee Web-Recon/fimap.txt
    fi
    
	
	if [[ ${choices[5]} ]]; then
        #Option 6 selected
	uniscan -u http://$TARGET/ -qdgj | tee Web-Recon/uniscan.txt
    fi

	if [[ ${choices[6]} ]]; then
        #Option 7 selected
		mkdir Service-Recon
	onesixtyone $TARGET | tee Service-Recon/onesixtyone.txt | tee Service-Recon/smtp-user-enum.txt
	snmpwalk $TARGET | tee Service-Recon/snmpwalk.txt | tee Service-Recon/smtp-user-enum.txt
    fi
	
	if [[ ${choices[7]} ]]; then
        #Option 8 selected
	smtp-user-enum -M VRFY -U /usr/share/seclists/Usernames/top_shortlist.txt -t $TARGET | tee Service-Recon/smtp-user-enum.txt
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
