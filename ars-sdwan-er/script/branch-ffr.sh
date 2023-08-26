#!/bin/sh
# Parameters
local_asn=$1
bgp_routerId=$2
bgp_network1=$3
peer_IP1=$4
peer_IP2=$5
rmt_asn=$6

# Enable IPv4 and IPv6 forwarding
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv6.conf.all.forwarding=1
sed -i "/net.ipv4.ip_forward=1/ s/# *//" /etc/sysctl.conf
sed -i "/net.ipv6.conf.all.forwarding=1/ s/# *//" /etc/sysctl.conf

# Enable NAT to Internet
iptables -t nat -A POSTROUTING -d 10.0.0.0/8 -j ACCEPT
iptables -t nat -A POSTROUTING -d 172.16.0.0/12 -j ACCEPT
iptables -t nat -A POSTROUTING -d 192.168.0.0/16 -j ACCEPT
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE


# Save to IPTables file for persistence on reboot
iptables-save > /etc/iptables/rules.v4

echo "Installing IPTables-Persistent"
echo iptables-persistent iptables-persistent/autosave_v4 boolean false | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean false | sudo debconf-set-selections
apt-get -y install iptables-persistent

## Install the frr routing daemon
echo "Installing frr"
curl -s https://deb.frrouting.org/frr/keys.asc | sudo apt-key add -
FRRVER="frr-stable"
echo deb https://deb.frrouting.org/frr $(lsb_release -s -c) $FRRVER | sudo tee -a /etc/apt/sources.list.d/frr.list

sudo apt-get -y update
sudo apt-get -y install frr frr-pythontools

##  run the updates and ensure the packages are up to date and there is no new version available for the packages
sudo apt-get -y update --fix-missing

## Create the configuration files for frr daemon
echo "add bgpd in daemon config file"
sed -i 's/bgpd=no/bgpd=yes/g' /etc/frr/daemons

echo "add FRR config"
cat <<EOF > /etc/frr/frr.conf
!
router bgp $local_asn
 bgp router-id $bgp_routerId
 no bgp ebgp-requires-policy
 network $bgp_network1
 neighbor $peer_IP1 remote-as $rmt_asn
 neighbor $peer_IP1 soft-reconfiguration inbound
 neighbor $peer_IP2 remote-as $rmt_asn
 neighbor $peer_IP2 soft-reconfiguration inbound
!
 address-family ipv6
 exit-address-family
 exit
!
line vty
!
EOF

## to start daemons at system startup
echo "enable frr at system startup"
systemctl enable frr

## run the daemons
echo "start frr daemons"
systemctl restart frr

sudo adduser azureuser frrvty
sudo adduser azureuser frr