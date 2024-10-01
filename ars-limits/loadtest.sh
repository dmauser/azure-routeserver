
### Deploy the lab
# Step 1: Deploy base lab
curl -sL https://raw.githubusercontent.com/dmauser/azure-routeserver/refs/heads/main/ars-nhip/script/1deploy.azcli | bash
# Step 2: Configure NVA Linux VMs with FRR and peer with ARS
curl -sL https://raw.githubusercontent.com/dmauser/azure-routeserver/refs/heads/main/ars-nhip/script/2deploy.azcli | bash

### Lab diagram
https://github.com/dmauser/azure-routeserver/blob/main/ars-nhip/media/validation2.png

### Using bastion log on az-hub-lxnva1 
# elevate to root
sudo -s
### backup frr config
cat /etc/frr/frr.conf > /etc/frr/frr.conf.bak

#### Run below the desired load test

### 1K routes: https://raw.githubusercontent.com/dmauser/azure-routeserver/refs/heads/main/ars-limits/1K-routes.txt
rm /var/log/frr/bgpd.log #clean logs
wget https://raw.githubusercontent.com/dmauser/azure-routeserver/refs/heads/main/ars-limits/1K-routes.txt
cp 1K-routes.txt /etc/frr/frr.conf
systemctl restart frr #restart FRR daemon.
tail -f /var/log/frr/bgpd.log

### 5K routes: https://raw.githubusercontent.com/dmauser/azure-routeserver/refs/heads/main/ars-limits/5K-routes.txt
rm /var/log/frr/bgpd.log #clean logs
wget https://raw.githubusercontent.com/dmauser/azure-routeserver/refs/heads/main/ars-limits/5K-routes.txt
cp 5K-routes.txt /etc/frr/frr.conf
systemctl restart frr #restart FRR daemon.
tail -f /var/log/frr/bgpd.log

### 10K routes: https://raw.githubusercontent.com/dmauser/azure-routeserver/refs/heads/main/ars-limits/10K-routes.txt
rm /var/log/frr/bgpd.log #clean logs
wget https://raw.githubusercontent.com/dmauser/azure-routeserver/refs/heads/main/ars-limits/10K-routes.txt
cp 10K-routes.txt /etc/frr/frr.conf
systemctl restart frr #restart FRR daemon.
tail -f /var/log/frr/bgpd.log

### 7280 routes: https://raw.githubusercontent.com/dmauser/azure-routeserver/refs/heads/main/ars-limits/7280-routes.txt
rm /var/log/frr/bgpd.log #clean logs
wget https://raw.githubusercontent.com/dmauser/azure-routeserver/refs/heads/main/ars-limits/7280-routes.txt
cp 7280-routes.txt /etc/frr/frr.conf
systemctl restart frr #restart FRR daemon.
tail -f /var/log/frr/bgpd.log

### 8K routes: https://raw.githubusercontent.com/dmauser/azure-routeserver/refs/heads/main/ars-limits/8K-routes.txt
rm /var/log/frr/bgpd.log #clean logs
wget https://raw.githubusercontent.com/dmauser/azure-routeserver/refs/heads/main/ars-limits/8K-routes.txt
cp 8K-routes.txt /etc/frr/frr.conf
systemctl restart frr #restart FRR daemon.
tail -f /var/log/frr/bgpd.log

### 6473 routes: https://raw.githubusercontent.com/dmauser/azure-routeserver/refs/heads/main/ars-limits/6473-routes.txt
rm /var/log/frr/bgpd.log #clean logs
wget https://raw.githubusercontent.com/dmauser/azure-routeserver/refs/heads/main/ars-limits/6473-routes.txt
cp 6473-routes.txt /etc/frr/frr.conf
systemctl restart frr #restart FRR daemon.
tail -f /var/log/frr/bgpd.log

### 6472 routes: https://raw.githubusercontent.com/dmauser/azure-routeserver/refs/heads/main/ars-limits/6472-routes.txt
rm /var/log/frr/bgpd.log #clean logs
wget https://raw.githubusercontent.com/dmauser/azure-routeserver/refs/heads/main/ars-limits/6472-routes.txt
cp 6472-routes.txt /etc/frr/frr.conf
systemctl restart frr #restart FRR daemon.
tail -f /var/log/frr/bgpd.log


