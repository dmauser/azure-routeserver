Login-AzAccount -Subscription "DMAUSER-FDPO"

# update powershell



# Stop an existing firewall

$azfw = Get-AzFirewall -Name "az-hub-azfw" -ResourceGroupName "lab-ars-sdwan"
$azfw.Deallocate()
Set-AzFirewall -AzureFirewall $azfw

# Start the firewall

$azfw = Get-AzFirewall -Name "az-hub-azfw" -ResourceGroupName "lab-ars-sdwan"
$vnet = Get-AzVirtualNetwork -ResourceGroupName "lab-ars-sdwan" -Name "az-hub-vnet"
$publicip1 = Get-AzPublicIpAddress -Name "az-hub-azfw-pip" -ResourceGroupName "lab-ars-sdwan"
$azfw.Allocate($vnet,@($publicip1))

Set-AzFirewall -AzureFirewall $azfw