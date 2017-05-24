#!/bin/sh
mkdir -p ../../riglet-logs/digital-platform-architects-minimal
ansible-playbook -i ./inventory -e @inputs -e @vars -e @../tmp/_tf_outputs.yml ./rancher_pipeline_2.yml > ../../riglet-logs/digital-platform-architects-minimal/rancher_pipeline_2.log
