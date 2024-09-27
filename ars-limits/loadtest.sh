### 5000 routes: https://raw.githubusercontent.com/dmauser/AzureVM-Router/master/conf/5000-bgproutes.txt
rm /var/log/frr/bgpd.log #clean logs
wget https://raw.githubusercontent.com/dmauser/AzureVM-Router/master/conf/5000-bgproutes.txt
cp 5000-bgproutes.txt /etc/frr/bgpd.conf
systemctl restart frr.service #restart FRR daemon.
tail -f /var/log/frr/bgpd.log