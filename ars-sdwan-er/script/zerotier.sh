#!/bin/sh
# Parameters
sudo curl -s https://install.zerotier.com | sudo bash
sudo zerotier-cli join 6ab565387ae92a6b

zerotier-cli info
zerotier-cli listnetworks
zerotier-cli listpeers
zerotier-cli peers
zerotier-cli listpeers | grep -oE '([0-9a-f]{10})' | xargs -I % zerotier-cli orbit % 6ab565387ae92a6b
zerotier-cli listmoons


echo | echo test1 && sleep 10 && echo test2