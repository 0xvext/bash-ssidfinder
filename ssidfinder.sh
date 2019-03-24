#!/bin/bash

echo "Stopping wlan0..."
ifconfig wlan0 down
echo "Setting wlan0 to monitor mode..."
iwconfig wlan0 mode monitor
echo "Starting wlan0..."
ifconfig wlan0 up
echo "Capturing 10000 frames on wlan0..."
tcpdump -nn -i wlan0 -c 10000 -w /tmp/ssids.pcap
echo "Dropping privileges and exporting pcap to /tmp/ssids.pcap.txt..."
sudo -u kaliroot tshark -r /tmp/ssids.pcap > /tmp/ssids.pcap.txt -n
echo '############Beacons only############'
comm -23 <( grep -E 'Beacon' /tmp/ssids.pcap.txt | cut -d, -f 6 | cut -d= -f 2 | sort -u ) <( comm -12 <( grep -E 'Probe Request' /tmp/ssids.pcap.txt | grep -v 'Malformed' | cut -d, -f 5 | cut -d= -f 2 | sort -u ) <( grep -E 'Probe Response' /tmp/ssids.pcap.txt | cut -d, -f 6 | cut -d= -f 2 | sort -u ) )
echo '#########Probe/Request pairs########'
comm -12 <( grep -E 'Probe Request' /tmp/ssids.pcap.txt | grep -v 'Malformed' | cut -d, -f 5 | cut -d= -f 2 | sort -u ) <( grep -E 'Probe Response' /tmp/ssids.pcap.txt | cut -d, -f 6 | cut -d= -f 2 | sort -u )
echo '########Pairs minus Beacons#########'
comm -13 <( grep -E 'Beacon' /tmp/ssids.pcap.txt | cut -d, -f 6 | cut -d= -f 2 | sort -u ) <( comm -12 <( grep -E 'Probe Request' /tmp/ssids.pcap.txt | grep -v 'Malformed' | cut -d, -f 5 | cut -d= -f 2 | sort -u ) <( grep -E 'Probe Response' /tmp/ssids.pcap.txt | cut -d, -f 6 | cut -d= -f 2 | sort -u ) )

echo '#########Stations involved##########'
comm -13 <( grep -E 'Beacon' /tmp/ssids.pcap.txt | cut -d, -f 6 | cut -d= -f 2 | sort -u ) <( comm -12 <( grep -E 'Probe Request' /tmp/ssids.pcap.txt | grep -v 'Malformed' | cut -d, -f 5 | cut -d= -f 2 | sort -u ) <( grep -E 'Probe Response' /tmp/ssids.pcap.txt | cut -d, -f 6 | cut -d= -f 2 | sort -u ) ) | while IFS= read -r line
  do
    grep "$line" /tmp/ssids.pcap.txt | grep -v 'ff:ff:ff:ff:ff:ff' | grep -v 'Malformed' | cut -b 18-57,123-200 | cut -d= -f 1,2 | sort -u
  done
