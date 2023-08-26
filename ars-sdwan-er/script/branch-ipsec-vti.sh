#!/bin/sh
# Parameters
left_ip=$1 #NVA Private IP
left_id=$2 #NVA Public IP
rigth_ip1=$3 # Desttination Public IP1
rigth_ip2=$4 # Desttination Public IP1

##  run the updates and ensure the packages are up to date and there is no new version available for the packages
sudo apt-get update 
sudo apt-get install -y strongswan

sudo mv /etc/ipsec.conf /etc/ipsec.conf.bak

cat <<EOF > /etc/ipsec.conf
#
# /etc/ipsec.conf
#
conn %default
        # Authentication Method : Pre-Shared Key
        leftauth=psk
        rightauth=psk
        # Encryption Algorithm : aes-128-cbc
        # Authentication Algorithm : sha1
        # Perfect Forward Secrecy : Diffie-Hellman Group 2
        ike=aes128-sha1-modp1024!
        # Lifetime : 28800 seconds
        ikelifetime=28800s
        # Phase 1 Negotiation Mode : main
        aggressive=no
        # Protocol : esp
        # Encryption Algorithm : aes-128-cbc
        # Authentication Algorithm : hmac-sha1-96
        # Perfect Forward Secrecy : Diffie-Hellman Group 2
        esp=aes128-sha1-modp1024!
        # Lifetime : 3600 seconds
        lifetime=3600s
        # Mode : tunnel
        type=tunnel
        # DPD Interval : 10
        dpddelay=10s
        # DPD Retries : 3
        dpdtimeout=30s
        # Tuning Parameters for AWS Remote Gateway:
        keyexchange=ikev1
        rekey=yes
        reauth=no
        dpdaction=restart
        closeaction=restart
        leftsubnet=0.0.0.0/0,::/0
        rightsubnet=0.0.0.0/0,::/0
        leftupdown=/etc/ipsec-vti.sh
        installpolicy=yes
        compress=no
        mobike=no
conn az-hub-lxnva1
        # Local Gateway: :
        left=$left_ip
        leftid=$left_id
        # Remote Gateway :
        right=$rigth_ip1
        rightid=$rigth_ip1
        auto=start
        mark=100
        #reqid=1
conn az-hub-lxnva2
        # Local Gateway: :
        left=$left_ip
        leftid=$left_id
        # Remote Gateway :
        right=$rigth_ip2
        rightid=$rigth_ip2
        auto=start
        mark=200
EOF

cat <<EOF > /etc/ipsec.secrets
# This file holds shared secrets or RSA private keys for authentication.

# RSA private key for this host, authenticating it to any other host
# which knows the public part.
$left_id $rigth_ip1 : PSK "abc123"
$left_id $rigth_ip2 : PSK "abc123"
EOF

#
# /etc/ipsec-vti.sh
#
IP=$(which ip)
IPTABLES=$(which iptables)

PLUTO_MARK_OUT_ARR=(${PLUTO_MARK_OUT//// })
PLUTO_MARK_IN_ARR=(${PLUTO_MARK_IN//// })
case "$PLUTO_CONNECTION" in
az-hub-lxnva1)
VTI_INTERFACE=vti1
VTI_LOCALADDR=169.254.1.1/30
VTI_REMOTEADDR=169.254.1.2/30
;;
az-hub-lxnva2)
VTI_INTERFACE=vti2
VTI_LOCALADDR=169.254.1.5/30
VTI_REMOTEADDR=169.254.1.6/30
;;
esac

case "${PLUTO_VERB}" in
up-client)
#$IP tunnel add ${VTI_INTERFACE} mode vti local ${PLUTO_ME} remote ${PLUTO_PEER} okey ${PLUTO_MARK_OUT_ARR[0]} ikey ${PLUTO_MARK_IN_ARR[0]}
$IP link add ${VTI_INTERFACE} type vti local ${PLUTO_ME} remote ${PLUTO_PEER} okey ${PLUTO_MARK_OUT_ARR[0]} ikey ${PLUTO_MARK_IN_ARR[0]}
sysctl -w net.ipv4.conf.${VTI_INTERFACE}.disable_policy=1
sysctl -w net.ipv4.conf.${VTI_INTERFACE}.rp_filter=2 || sysctl -w net.ipv4.conf.${VTI_INTERFACE}.rp_filter=0
$IP addr add ${VTI_LOCALADDR} remote ${VTI_REMOTEADDR} dev ${VTI_INTERFACE}
$IP link set ${VTI_INTERFACE} up mtu 1436
$IPTABLES -t mangle -I FORWARD -o ${VTI_INTERFACE} -p tcp -m tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
$IPTABLES -t mangle -I INPUT -p esp -s ${PLUTO_PEER} -d ${PLUTO_ME} -j MARK --set-xmark ${PLUTO_MARK_IN}
$IP route flush table 220
#/etc/init.d/bgpd reload || /etc/init.d/quagga force-reload bgpd
;;
down-client)
#$IP tunnel del ${VTI_INTERFACE}
$IP link del ${VTI_INTERFACE}
$IPTABLES -t mangle -D FORWARD -o ${VTI_INTERFACE} -p tcp -m tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
$IPTABLES -t mangle -D INPUT -p esp -s ${PLUTO_PEER} -d ${PLUTO_ME} -j MARK --set-xmark ${PLUTO_MARK_IN}
;;
esac

# Enable IPv4 forwarding
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv4.conf.eth0.disable_xfrm=1
sysctl -w net.ipv4.conf.eth0.disable_policy=1

sudo systemctl restart strongswan