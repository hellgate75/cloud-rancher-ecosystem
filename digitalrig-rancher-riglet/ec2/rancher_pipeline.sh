#!/bin/sh
mkdir -p ../../riglet-logs/digital-platform-architects
ansible-playbook -i ./inventory -e @inputs -e @vars -e @../tmp/_tf_outputs.yml ./rancher_pipeline.yml > ../../riglet-logs/digital-platform-architects/rancher_pipeline.log
