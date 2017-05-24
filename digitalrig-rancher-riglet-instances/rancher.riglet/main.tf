provider "aws" {
  region = "${var.region}"
}

module "rancher" {
  source = "../../digitalrig-rancher-iaas-modules/terraform/modules/aws/rancher"
  /*source = "git::ssh://git@bitbucket.org/digitalrigbitbucketteam/digitalrig-iaas-modules.git//terraform/modules/aws/rancher?source=enhancement/rancheros"*/

  region = "${var.region}"
  vpc-net-cidr = "${var.vpc-net-cidr}"
  dmz-net-cidr = "${var.dmz-net-cidr}"
  dmz-availability-zone = "${var.dmz-availability-zone}"
  internal-net-cidr = "${var.internal-net-cidr}"
  internal-net-prefix = "${var.internal-net-prefix}"
  internal-availability-zone = "${var.internal-availability-zone}"

  ansible-domain = "${var.ansible-domain}"
  route-53-domain-id = "${var.route-53-domain-id}"
  ad-type = "${var.ad-type}"

  ad-krb-realm = "${var.ad-krb-realm}"
  krb-domain = "${var.krb-domain}"
  base-dn = "${var.base-dn}"
  ad-password = "${var.ad-password}"

  keypair = "${var.keypair}"
  internal-keypair = "${var.internal-keypair}"

  # Change the inventory name to be used, only if needed
  ansible-inventory = "riglet-rancher"
  dr-scripts-ref = "${var.dr-scripts-ref}"
  digitalrig-riglet-ref = "${var.digitalrig-riglet-ref}"
  platform-ref = "${var.platform-ref}"

  default-linux-ami = "${var.default-linux-ami}"
  rancheros-ami = "${var.rancheros-ami}"

  vpn-knock-lower-port = "${var.vpn-knock-lower-port}"
  vpn-knock-upper-port = "${var.vpn-knock-upper-port}"
}

output "rancher-front-end-private-ip" {
  value = "${module.rancher.aws-rancher-front-end-private-ip}"
}

output "rancher-front-end-public-ip" {
  value = "${module.rancher.aws-rancher-front-end-public-ip}"
}

output "rancher-ha-db-private-ip" {
  value = "${module.aws-rancher-ha-db-private-ip}"
}

output "rancher-server-master-private-ip" {
  value = "${module.rancher.aws-rancher-server-master-private-ip}"
}

output "rancher-server-slave-private-ip" {
  value = "${module.rancher.aws-rancher-server-slave-private-ip}"
}

output "rancher-app-1-private-ip" {
  value = "${module.rancher.aws-rancher-app-1-private-ip}"
}

output "rancher-app-2-private-ip" {
  value = "${module.rancher.aws-rancher-app-2-private-ip}"
}

output "rancher-app-3-private-ip" {
  value = "${module.rancher.aws-rancher-app-3-private-ip}"
}

output "rancher-infra-1-private-ip" {
  value = "${module.rancher.aws-rancher-infra-1-private-ip}"
}

output "rancher-infra-1-1-private-ip" {
  value = "${module.rancher.aws-rancher-infra-1-1-private-ip}"
}

output "rancher-infra-1-2-private-ip" {
  value = "${module.rancher.aws-rancher-infra-1-2-private-ip}"
}

output "rancher-infra-2-private-ip" {
  value = "${module.rancher.aws-rancher-infra-2-private-ip}"
}

output "rancher-infra-2-1-private-ip" {
  value = "${module.rancher.aws-rancher-infra-2-1-private-ip}"
}

output "rancher-infra-2-2-private-ip" {
  value = "${module.rancher.aws-rancher-infra-2-2-private-ip}"
}

output "rancher-infra-3-private-ip" {
  value = "${module.rancher.aws-rancher-infra-3-private-ip}"
}

output "rancher-infra-3-1-private-ip" {
  value = "${module.rancher.aws-rancher-infra-3-1-private-ip}"
}

output "rancher-infra-3-2-private-ip" {
  value = "${module.rancher.aws-rancher-infra-3-2-private-ip}"
}

output "openvpn-host" {
  value = "${module.rancher.openvpn-dns}"
}

output "ad-admin-box-ip" {
  value = "${module.rancher.aws-admin-private-ip}"
}

output "ad-dns-1" {
  value = "${module.rancher.ad-dns-1}"
}

output "ad-dns-2" {
  value = "${module.rancher.ad-dns-2}"
}

output "riglet-vpc-id" {
  value = "${module.rancher.default-vpc-id}"
}

output "rig-internal-route-table-id" {
 value = "${module.rancher.internal-route-table-id}"
}

output "rig-dmz-route-table-id" {
 value = "${module.rancher.dmz-route-table-id}"
}

output "rig-route53-internal-zone-id" {
 value = "${module.rancher.route53-internal-zone-id}"
}

output "rig-default-security-group-id" {
  value = "${module.rancher.default-security-group-id}"
}

output "rig-private-subnet-id" {
  value = "${module.rancher.private-subnet-id}"
}
