# Azure Route Server Next Hop IP lab

## Intro

The main objective of this lab is to demonstrate the benefit of the [Azure Route Server next hop IP feature](https://)

- Demonstrate basic connectivity between Spokes via Hub
- Deploy Azure Route Server and use NVA to allow Spoke-to-Spoke connectivity without UDRs
- Describe the default behavior for traffic going over high-available NVAs when using Azure Route Server.
- Introduce stateful inspection via iptables on the NVAs and demonstrate the side effects of asymmetric routing for spoke-to-spoke connectivity (East/West traffic).
- Demonstrate the Azure Route Server Next Hop IP feature and how it solves potential asymmetric issues, and spoke-to-spoke go over NVAs doing stateful inspection.

### Base network topology

![](./media/network-topolgy.png)

### Lab components

- There are three Virtual Networks (VNETs) where we have a Hub (10.0.0.0/24), Spoke1 (10.0.1.0/24) and Spoke2 (10.0.2.0/24).
- Hub VNET has three virtual machines (VMs): az-hub-lxvm, az-spk1-lxvm and az-spk2-lxvm).
- Azure Route Server (az-hub-routeserver) and that will be peer ti.

### Considerations

### Task 1: Deploy base lab and test connectivity

#### Deploy

Use the following script to deploy the base lab:

```bash
wget -O 1deploy.sh https://raw.githubusercontent.com/dmauser/azure-routeserver/main/ars-nhip/1deploy.azcli
chmod +xr 1deploy.sh
./1deploy.sh
```

#### Validate transit between Spoke1 and Spoke2 VMs and setup UDRs

This step aims to validate the connectivity between both VMs in Spoke1 and Spoke2 VNETs.
It will demonstrate the connectivity using UDR via Load Balancer with both NVAs in the Hub.

```Bash
#Parameters
rg=lab-ars-nhip #Define your resource group
#Define parameters for Azure Hub and Spokes:
AzurehubName=az-hub #Azure Hub Name
Azurespoke1Name=az-spk1 #Azure Spoke 1 name
Azurespoke2Name=az-spk2 #Azure Spoke 1 name
location=$(az group show -n $rg --query location -o tsv)

# Check Spoke VMs route tables
echo Check Spoke VMs Route tables:
echo $Azurespoke1Name-lxvm &&\
az network nic show --resource-group $rg -n $Azurespoke1Name-lxvm-nic --query "ipConfigurations[].privateIpAddress" -o tsv &&\
az network nic show-effective-route-table --resource-group $rg -n $Azurespoke1Name-lxvm-nic -o table &&\
echo $Azurespoke2Name-lxvm &&\
az network nic show --resource-group $rg -n $Azurespoke2Name-lxvm-nic --query "ipConfigurations[].privateIpAddress" -o tsv &&\
az network nic show-effective-route-table --resource-group $rg -n $Azurespoke2Name-lxvm-nic -o table

# Can az-spk1-lxvm1 reach az-spk2-lxvm2?
# Use Bastion or Serial console to access az-SPK1-lxvm:
# Run the following to SPK2-lxvm1
ping 10.0.2.4 -c 5
sudo hping3 10.0.2.4 -S -p 80 -c 10
curl 10.0.2.4

# Access Bastion or Serial console on az-SPK2-lxvm:
# Run the following
ping 10.0.1.4 -c 5
sudo hping3 10.0.1.4 -S -p 80 -c 10
curl 10.0.1.4

# How about connectivity to Hub-lxvm1 vm? Does it work?
ping 10.0.0.4 -c 5
sudo hping3 10.0.0.4 -S -p 80 -c 10
curl 10.0.0.4

# add UDR to NVA1 and re-validate connectivity

#UDR for Hub traffic to Azure NVA (disables BGP propagation)
## Create UDR + Disable BGP Propagation
nvalb=$(az network lb show -g $rg --name $AzurehubName-lxnva-ilb --query "frontendIpConfigurations[].privateIpAddress" -o tsv)
## Create UDR
az network route-table create --name rt-spoke-to-nva --resource-group $rg --location $location --disable-bgp-route-propagation true --output none
## Default and private traffic to the NVA Load Balancer:
az network route-table route create --resource-group $rg --name default-to-NVA --route-table-name rt-spoke-to-nva  \
--address-prefix 0.0.0.0/0 \
--next-hop-type VirtualAppliance \
--next-hop-ip-address $nvalb \
--output none
az network route-table route create --resource-group $rg --name private-traffic-to-NVA --route-table-name rt-spoke-to-nva  \
--address-prefix 10.0.0.0/16 \
--next-hop-type VirtualAppliance \
--next-hop-ip-address $nvalb \
--output none
# Associate to the Spoke 1 and 2 VM subnets
az network vnet subnet update -n subnet1 -g $rg --vnet-name $Azurespoke1Name-vnet --route-table rt-spoke-to-nva --output none
az network vnet subnet update -n subnet1 -g $rg --vnet-name $Azurespoke2Name-vnet --route-table rt-spoke-to-nva --output none

# Check Spoke VMs route tables (it may take few sconds to take effect the UDR changes made, re-run commands below until see expected route tables)
echo Check Spoke VMs Route tables:
echo $Azurespoke1Name-lxvm &&\
az network nic show --resource-group $rg -n $Azurespoke1Name-lxvm-nic --query "ipConfigurations[].privateIpAddress" -o tsv &&\
az network nic show-effective-route-table --resource-group $rg -n $Azurespoke1Name-lxvm-nic -o table &&\
echo $Azurespoke2Name-lxvm &&\
az network nic show --resource-group $rg -n $Azurespoke2Name-lxvm-nic --query "ipConfigurations[].privateIpAddress" -o tsv &&\
az network nic show-effective-route-table --resource-group $rg -n $Azurespoke2Name-lxvm-nic -o table

# Expected output:
:'
az-spk1-lxvm
10.0.1.4
Source    State    Address Prefix    Next Hop Type     Next Hop IP
--------  -------  ----------------  ----------------  -------------
Default   Active   10.0.1.0/24       VnetLocal
Default   Active   10.0.0.0/24       VNetPeering
Default   Invalid  0.0.0.0/0         Internet
User      Active   0.0.0.0/0         VirtualAppliance  10.0.0.166
User      Active   10.0.0.0/16       VirtualAppliance  10.0.0.166
az-spk2-lxvm
10.0.2.4
Source    State    Address Prefix    Next Hop Type     Next Hop IP
--------  -------  ----------------  ----------------  -------------
Default   Active   10.0.2.0/24       VnetLocal
Default   Active   10.0.0.0/24       VNetPeering
Default   Invalid  0.0.0.0/0         Internet
User      Active   0.0.0.0/0         VirtualAppliance  10.0.0.166
User      Active   10.0.0.0/16       VirtualAppliance  10.0.0.166
'
# Use Bastion or Serial console to access az-SPK1-lxvm:
# Run the following to SPK2-lxvm1 to check connectivity:
ping 10.0.2.4 -c 5 -O
sudo hping3 10.0.2.4 -S -p 80 -c 10
curl 10.0.2.4

# Access Bastion or Serial console on az-SPK2-lxvm:
# Run the following
ping 10.0.1.4 -c 5
sudo hping3 10.0.1.4 -S -p 80 -c 10
curl 10.0.1.4

# IMPORTANT: Dissassociate the UDRs from the Spoke 1 and 2 VM subnets before moving to the next step.
az network vnet subnet update -n subnet1 -g $rg --vnet-name $Azurespoke1Name-vnet --route-table "" --output none
az network vnet subnet update -n subnet1 -g $rg --vnet-name $Azurespoke2Name-vnet --route-table "" --output none
```

### Task 2: Enable Azure Route Server BGP peering with NVAs

#### Deploy

In the steps below, the script will build BGP peerings between both NVAs (az-hub-lxnva1 and az-hub-lxnva1) with Azure Route Server instances. UDRs have been removed from the previous step and the goal is to show Spoke1 and Spoke2 transit via NVAs in the Hub VNET.

```Bash
#Parameters
rg=lab-ars-nhip #Define your resource group
location=$(az group show -n $rg --query location -o tsv)

# NVA specific parameters
nvasubnetname=nvasubnet
nvasubnetprefix="10.0.0.160/28"
nvaname=nva
instances=2 #NVA instances
#Specific NVA BGP settings
asn_quagga=65004 # Set ASN
# Set Networks to be propagated
bgp_network1=0.0.0.0/0 #Default Route Propagation
bgp_network2=10.0.0.0/16 #Summary route for Hub/Spoke transit

#Define parameters for Azure Hub and Spokes:
AzurehubName=az-hub #Azure Hub Name
Azurespoke1Name=az-spk1 #Azure Spoke 1 name
Azurespoke2Name=az-spk2 #Azure Spoke 1 name

# Peer with Route Server
echo Peering NVAs with Route Server
nvanames=$(az vm list -g $rg --query '[?contains(name,`'$nvaname'`)].name' -o tsv)
for nvaintname in $nvanames
do
 #NVA BGP config variables (do not change)
 bgp_routerId=$(az network nic show --name "$nvaintname"VMNic --resource-group $rg --query ipConfigurations[0].privateIpAddress -o tsv)
 routeserver_IP1=$(az network routeserver list --resource-group $rg --query '{IPs:[0].virtualRouterIps[0]}' -o tsv)
 routeserver_IP2=$(az network routeserver list --resource-group $rg --query '{IPs:[0].virtualRouterIps[1]}' -o tsv)

 # Enabling routing, NAT and BGP on Linux NVA:
 echo Enabling routing, NAT and BGP on Linux NVA $nvaintname
 scripturi="https://raw.githubusercontent.com/dmauser/azure-routeserver/main/ars-nhip/script/linuxrouterbgp.sh"
 az vm extension set --resource-group $rg --vm-name $nvaintname --name customScript --publisher Microsoft.Azure.Extensions \
 --protected-settings "{\"fileUris\": [\"$scripturi\"],\"commandToExecute\": \"./linuxrouterbgp.sh $asn_quagga $bgp_routerId $bgp_network1 $bgp_network2 $routeserver_IP1 $routeserver_IP2 $nexthopip\"}" \
 --force-update \
 --no-wait 

 # Building Route Server BGP Peering
 echo Building BGP Peering between $AzurehubName-routeserver and $nvaintname
 az network routeserver peering create --resource-group $rg --routeserver $AzurehubName-routeserver --name $nvaintname --peer-asn $asn_quagga \
 --peer-ip $(az network nic show --name "$nvaintname"VMNic --resource-group $rg --query ipConfigurations[0].privateIpAddress -o tsv) \
 --output none
done
```

#### Validate connectivity between Spoke1 and Spoke2 VMs

```Bash
#Parameters
rg=lab-ars-nhip #Define your resource group
#Define parameters for Azure Hub and Spokes:
AzurehubName=az-hub #Azure Hub Name
Azurespoke1Name=az-spk1 #Azure Spoke 1 name
Azurespoke2Name=az-spk2 #Azure Spoke 1 name

# Validations after enabling Route Server peering 
echo Check Spoke VMs Route tables:
echo $Azurespoke1Name-lxvm &&\
az network nic show --resource-group $rg -n $Azurespoke1Name-lxvm-nic --query "ipConfigurations[].privateIpAddress" -o tsv &&\
az network nic show-effective-route-table --resource-group $rg -n $Azurespoke1Name-lxvm-nic -o table &&\
echo $Azurespoke2Name-lxvm &&\
az network nic show --resource-group $rg -n $Azurespoke2Name-lxvm-nic --query "ipConfigurations[].privateIpAddress" -o tsv &&\
az network nic show-effective-route-table --resource-group $rg -n $Azurespoke2Name-lxvm-nic -o table

# Can az-spk1-lxvm reach az-spk2-lxvm?
# Access Bastion or Serial console on az-spk1-lxvm:
# Run the following
ping 10.0.2.4 -c 5
sudo hping3 10.0.2.4 -S -p 80 -c 10
curl 10.0.2.4
# Check also from the opposite side. From az-spk2-lxvm to az-spk1-lxvm.
ping 10.0.1.4 -c 5
sudo hping3 10.0.1.4 -S -p 80 -c 10
curl 10.0.1.4

# Run TCP traceroute to check BGP ECMP first hop NVA1 and NVA2 may change.
# Run command below multiple times to see IP change on the first hop (NVAs).
# from az-spk1-lxvm
tcptraceroute 10.0.2.4 80
# from az-spk2-lxvm
tcptraceroute 10.0.1.4 80

# Review Route Server configuration:

#Route Server config
# RS instance IPs
rsname=$(az network routeserver list --resource-group $rg --query [].name -o tsv)
echo Route Server IPs: && \
az network routeserver list --resource-group $rg --query '[].virtualRouterIps[]' -o tsv && \
echo -e && \
# RS BGP peerings
echo Route Server BGP peerings: && \
az network routeserver peering list --resource-group $rg --routeserver $rsname -o table && \
echo -e && \
# RS advertised routes to NVA1 and NVA2
for nva in $(az vm list -g $rg --query '[?contains(name,`'$nvaname'`)].name' -o tsv)
do
  echo Advertised routes from RS $rsname to $nva
  az network routeserver peering list-advertised-routes \
   --resource-group $rg \
   --name $nva \
   --routeserver $rsname \
   --query "[RouteServiceRole_IN_0,RouteServiceRole_IN_1][]" \
   --output table
  echo -e
done && \
# RS learned routes
for nva in $(az vm list -g $rg --query '[?contains(name,`'$nvaname'`)].name' -o tsv)
do
  echo Learned routes on RS $rsname from $nva
  az network routeserver peering list-learned-routes \
   --resource-group $rg \
   --name $nva \
   --routeserver $rsname \
   --query "[RouteServiceRole_IN_0,RouteServiceRole_IN_1][]" \
   --output table
  echo -e
done

# Optional - review NVA BGP configuration
# 1) Access either NVAs or both and run the following commands:
# 2) Elevate shell as root by running
sudo -s
# Review BGP config by running both commands:
vtysh 
show running-config
show ip bgp
show ip bgp summary
show ip bgp neighbors
show ip bgp neighbors 10.0.0.132 received-routes
show ip bgp neighbors 10.0.0.132 advertised-routes
show ip bgp neighbors 10.0.0.133 received-routes
show ip bgp neighbors 10.0.0.133 advertised-routes
```

### Task 3: enabling traffic inspection on the NVAs

In this section, both NVAs and how that will affect transit between Spoke 1 and Spoke 2 VMs.

#### Deploy

Enabling IPtables:

```Bash
#Parameters
rg=lab-ars-nhip #Define your resource group

#Enable IPTables on both NVAs by allowing ICMP and TCP ports 80, 53, 443, 22, and 5201
echo 'Enable IPTables NVA by allowing ICMP, TCP ports 80, 53, 443, 22, and 5201'
nvanames=$(az vm list -g $rg --query '[?contains(name,`'$nvaname'`)].name' -o tsv)
for nvaintname in $nvanames
do
 # Enable routing, NAT and BGP on Linux NVA:
 echo Enabling IPtables rules on $nvaintname
 scripturi="https://raw.githubusercontent.com/dmauser/azure-routeserver/main/ars-nhip/script/iptables.sh"
 az vm extension set --resource-group $rg --vm-name $nvaintname --name customScript --publisher Microsoft.Azure.Extensions \
 --protected-settings "{\"fileUris\": [\"$scripturi\"],\"commandToExecute\": \"./iptables.sh\"}" \
 --force-update \
 --output none
done
```

#### Validate connectivity after IPtables enabled

```Bash
# Review the IPtables rules enforced by using the following link:
https://raw.githubusercontent.com/dmauser/azure-routeserver/main/ars-nhip/script/iptables.sh

# Can az-spk1-lxvm reach az-spk2-lxvm?
# Access Bastion or Serial console on az-spk1-lxvm:
# Run the following commands
ping 10.0.2.4 -c 5
sudo hping3 10.0.2.4 -S -p 80 -c 10
curl 10.0.2.4
# Check also from the opposite side. From az-spk2-lxvm to az-spk1-lxvm.
ping 10.0.1.4 -c 5
sudo hping3 10.0.1.4 -S -p 80 -c 10
curl 10.0.1.4

# Note ping will fail because is not allowed by the rule.

# Run TCP traceroute to check BGP ECMP first hop NVA1 and NVA2 may change.
# Run command below multiple times to see IP change on the first hop (NVAs).
# from az-spk1-lxvm
tcptraceroute 10.0.2.4 80
# from az-spk2-lxvm
tcptraceroute 10.0.1.4 80

# (OPTIONAL) Review IPtables and start network captures running on both NVA1 and NVA2
sudo iptables -L -v #review Forward IP table rules
sudo tcpdump -n host 10.0.1.4 and host 10.0.2.4

# ====> Turn off one of the NVAs above and re-run the same tests:
# Check the route table after one of the NVAs are offline
echo Check Spoke VMs Route tables:
echo $Azurespoke1Name-lxvm &&\
az network nic show --resource-group $rg -n $Azurespoke1Name-lxvm-nic --query "ipConfigurations[].privateIpAddress" -o tsv &&\
az network nic show-effective-route-table --resource-group $rg -n $Azurespoke1Name-lxvm-nic -o table
echo $Azurespoke2Name-lxvm &&\
az network nic show --resource-group $rg -n $Azurespoke2Name-lxvm-nic --query "ipConfigurations[].privateIpAddress" -o tsv &&\
az network nic show-effective-route-table --resource-group $rg -n $Azurespoke2Name-lxvm-nic -o table

# Can az-spk1-lxvm1 reach az-spk2-lxvm2?
# Access Bastion or Serial console on az-SPK1-lxvm:
# Run the following commands on SPK2-lxvm1
sudo hping3 10.0.2.4 -S -p 80 -c 10
curl 10.0.2.4

# Access Bastion or Serial console on az-SPK2-lxvm:
# Run the following commands
sudo hping3 10.0.1.4 -S -p 80 -c 10
curl 10.0.1.4

# ===========> Bring back the NVA and make sure both are up and running.

# Optional - review NVA BGP configuration
# 1) Access either NVAs or both and run the following commands:
# 2) Elevate shell as root by running
sudo -s
# Review BGP config by running both commands:
vtysh 
show running-config
show ip bgp
show ip bgp summary
show ip bgp neighbors
show ip bgp neighbors 10.0.0.132 received-routes
show ip bgp neighbors 10.0.0.132 advertised-routes
show ip bgp neighbors 10.0.0.133 received-routes
show ip bgp neighbors 10.0.0.133 advertised-routes
```