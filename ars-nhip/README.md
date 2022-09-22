# Azure Route Server Next Hop IP lab

## Intro

The main objective of this lab is to demonstrate the benefit of the [Azure Route Server next hop IP feature](https://)

- Demonstrate basic connectivity between Spokes via Hub
- Deploy Azure Route Server and use NVA to allow Spoke-to-Spoke connectivity without UDRs
- Describe the default behavior for traffic going over high-available NVAs when using Azure Route Server.
- Introduce stateful inspection via iptables on the NVAs and demonstrate the side effects of asymetric routing for spoke-to-spoke connectivity (East/West traffic).
- Demonstrate the Azure Route Server Next Hop IP feature and how it solves potential asymetric issues and spoke-to-spoke go over NVAs doing stateful inspection.

### Base network topology

![](./media/network-topolgy.png)

### Task 1: Deploy base lab and validate connectivity

### Deploy

```bash
wget -O 1deploy.sh https://raw.githubusercontent.com/dmauser/azure-routeserver/main/ars-nhip/1deploy.azcli
chmod +xr 1deploy.sh
./1deploy.sh
```

### Validate



## Challenge 2 : Enable Azure Route Server peering

### Deploy

### Validate

## Challenge 3 : 