#!/bin/bash
sudo docker run -d --hostname=localhost --name rancher-server --privileged --restart=unless-stopped -p 8080:8080 rancher/server
