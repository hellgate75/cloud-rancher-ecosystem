# digital-rancher

## Goals

This project relizes a RIG instance on following cloud providers:
* Amazon Web Service

## Technology

Ansible python scripts.

## Implementations

This project has following implementations:

Amazon Web Services
* [minimal](/digitalrig-rancher-riglet/ec2-minimal) - Development/Studies RIG, with a single Rancher Server node with Cattle (RIG2) and Kubernetes (RIG3) Rancher Server environments
* [regular](/digitalrig-rancher-riglet/ec2) - Prduction RIG, with an HA AZ Failover Rancher Server cluster and multiple environments: Cattle (RIG2), Kubernetes (RIG3), Mesos (Experimental), Swarm Nodes [Portainer] (Experimental)

## Suggested images for creating multiple nodes via machine driver

Here tested and references of images for cloud machine-driver host dynamic creation
* *Amazon Web Services* : suggested AMI rancheros-v0.9.0-hvm-1 (ami-0b5b7f6e) tested with user : rancher, with overlaying disk driver

## What is provided with the installation ?

The folowing resource are provided with the installation :
* Rancher Infrastructure (Dev or Prod)
* Rancher Architecture set-up
* Rancher Multiple Environments set-up
* Pipelines Deployment (RIG2 right now)

## How-to play this project?

Follow the installation guides provided in each implementation.

## License

Copyright (c) 2016-2017 [BuildIt, Inc.](http://buildit.digital)

Licensed under the [MIT](/LICENSE) License (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

[https://opensource.org/licenses/MIT](https://opensource.org/licenses/MIT)

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
