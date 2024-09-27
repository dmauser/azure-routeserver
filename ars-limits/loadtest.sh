
### Deploy the lab

### backup frr config
cat /etc/frr/frr.conf > /etc/frr/frr.conf.bak

### 5000 routes: https://raw.githubusercontent.com/dmauser/azure-routeserver/refs/heads/main/ars-limits/5000-routes.txt
rm /var/log/frr/bgpd.log #clean logs
wget https://raw.githubusercontent.com/dmauser/azure-routeserver/refs/heads/main/ars-limits/5000-routes.txt
cp 5000-routes.txt /etc/frr/frr.conf
systemctl restart frr #restart FRR daemon.
tail -f /var/log/frr/bgpd.log


### 10K routes: https://raw.githubusercontent.com/dmauser/azure-routeserver/refs/heads/main/ars-limits/10K-routes.txt
rm /var/log/frr/bgpd.log #clean logs
wget https://raw.githubusercontent.com/dmauser/azure-routeserver/refs/heads/main/ars-limits/10K-routes.txt
cp 10K-routes.txt /etc/frr/frr.conf
systemctl restart frr #restart FRR daemon.
tail -f /var/log/frr/bgpd.log