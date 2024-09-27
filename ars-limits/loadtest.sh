
### Deploy the lab

### backup frr config
cat /etc/frr/frr.conf > /etc/frr/frr.conf.bak

### 5K routes: https://raw.githubusercontent.com/dmauser/azure-routeserver/refs/heads/main/ars-limits/5000-routes.txt
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

