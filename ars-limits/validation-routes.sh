# Optional: set the subscription
az account set -s VSE-Sub
# Resource group
rg=lab-ars-nhip

# Loop this comand above to happen every 15 seconds
while true; do az network nic show-effective-route-table -g $rg -n az-hub-lxvm-nic -o table | grep "VirtualNetworkGateway" | wc -l; sleep 15; done

##### Route files validation #####

# on the file 7280-routes.txt count grep for network 
cat ./ars-limits/7280-routes.txt | grep "network" | wc -l

# on the file 5K-routes.txt count grep for network
cat ./ars-limits/5K-routes.txt | grep "network" | wc -l

# on the file 6473-routes.txt count grep for network
cat ./ars-limits/6473-routes.txt | grep "network" | wc -l

# on the file 6472-routes.txt count grep for network
cat ./ars-limits/6472-routes.txt | grep "network" | wc -l

# on the file 10K-routes.txt count grep for network 
cat ./ars-limits/10K-routes.txt | grep " network 10" | wc -l

# on the file 1K-routes.txt count grep for network 
cat ./ars-limits/1K-routes.txt | grep " network 10" | wc -l