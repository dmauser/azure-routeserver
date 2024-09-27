az account set -s VSE-Sub
rg=lab-ars-nhip

# get az-hub-lxvm-nic effective routes and grep Virtual network gateway -o table
az network nic show-effective-route-table -g $rg -n az-hub-lxvm-nic  -o table | grep "VirtualNetworkGateway"

# now count how many routes are there in the effective route table filter by VirtualNetworkGateway
az network nic show-effective-route-table -g $rg -n az-hub-lxvm-nic  -o table | grep "VirtualNetworkGateway" | wc -l


# on the file 7280-routes.txt count grep for network 
cat ./ars-limits/7280-routes.txt | grep "network" | wc -l

# on the file 5000-routes.txt count grep for network
cat ./ars-limits/5000-routes.txt | grep "network" | wc -l