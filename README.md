# Azure Route Server

This repo is consolidation important references about Azure Route Server:

## Azure Route Server
- [Forced Tunneling of Internet traffic through Active-Active OPNsense Firewalls using Azure Route Server (ExpressRoute)](https://github.com/dmauser/Lab/tree/master/RS-AA-OPNsense-ForceTunnel-ER)
- [Transit between ExpressRoute and Azure S2S VPN using Route Server](https://github.com/dmauser/Lab/tree/master/RS-ER-VPN-Gateway-Transit)
- [Using Azure Firewall to inspect traffic between VPN and ExpressRoute](https://github.com/dmauser/Lab/tree/master/RS-ER-VPN-Gateway-Transit-AzFW)

## Considerations

- Default route (0.0.0.0/0) does not propagate over VPN Virtual Network Gateway (VNG).
    - Solution: Split 0.0.0.0/0 in two networks 0.0.0.0/1 and 128.0.0.0/1 and VPN VNG will be able to advertise that split range to the other side.

## Recommended references

- Hands-on learning using [Azure Route Server Microhack](https://github.com/malgebary/Azure-Route-Server-MicroHack).

- **Cloudtrooper Blog** by [Jose Moreno](https://github.com/erjosito/) - A must read blog for several scenarios related to [Azure Route Server](https://github.com/erjosito).

- Recommended links to review before deploying Azure Route Server:
    - [Azure Route Server FAQ](https://docs.microsoft.com/en-us/azure/route-server/route-server-faq)
    - [Troubleshooting Azure Route Server issues](https://docs.microsoft.com/en-us/azure/route-server/troubleshoot-route-server)