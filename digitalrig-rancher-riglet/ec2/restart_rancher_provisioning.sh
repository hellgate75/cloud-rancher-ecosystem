#!/bin/sh
mkdir -p ../../riglet-logs/digital-platform-architects
ansible-playbook --limi=@/Users/hellgate75/workspaces/digitalrig-riglet/rancheros-ec2/on_vpn_rancher.retry -i ./inventory -e @inputs -e @vars -e @../tmp/_tf_outputs.yml on_vpn_rancher.yml >> ../../riglet-logs/digital-platform-architects/rancher_on_vpn_provision_vms.log
