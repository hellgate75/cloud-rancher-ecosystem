resource "aws_instance" "nat" {
  ami = "${coalesce(var.nat-ami, lookup(var.default-nat-ami, var.region))}"
  # this is a special ami preconfigured to do NAT
  instance_type = "t2.micro"
  key_name = "${var.internal-keypair}"
  vpc_security_group_ids = [
    "${aws_security_group.default.id}"]
  subnet_id = "${aws_subnet.dmz.id}"
  source_dest_check = false
  associate_public_ip_address = false
  user_data = "nat"
  tags {
    Name = "${var.ansible-domain}-nat"
  }
}

## OVPN box
resource "aws_instance" "ovpn" {
  ami = "${coalesce(var.linux-ami, lookup(var.default-linux-ami, var.region))}"
  instance_type = "t2.micro"
  key_name = "${var.internal-keypair}"
  vpc_security_group_ids = [
    "${aws_security_group.default.id}",
    "${aws_security_group.ovpn.id}"]
  subnet_id = "${aws_subnet.dmz.id}"
  source_dest_check = false
  associate_public_ip_address = true
  user_data = "${replace("${data.template_file.client_cloud_config.rendered}", "REPLACE_HOSTNAME", "ovpn")}"
  tags {
    Name = "${var.ansible-domain}-ovpn"
    Role = "ovpn,ad-client"
    Rig = "${var.ansible-domain}"

  }
}

# OpenVPN Public DNS
resource "aws_route53_record" "ovpn-pub" {
  zone_id = "${var.route-53-domain-id}"
  name = "ovpn.ext.${var.ansible-domain}"
  type = "A"
  ttl = "60"
  records = [
    "${aws_instance.ovpn.public_ip}"]
}

output "openvpn-dns" {
  value = "${aws_route53_record.ovpn-pub.fqdn}"
}

# OpenVPN private DNS record
resource "aws_route53_record" "ovpn" {
  zone_id = "${aws_route53_zone.internal-zone.id}"
  name = "ovpn"
  type = "A"
  ttl = "60"
  records = [
    "${aws_instance.ovpn.private_ip}"]
}

## Front-End box
resource "aws_instance" "front-end" {
  ami = "${coalesce(var.linux-ami, lookup(var.default-linux-ami, var.region))}"
  instance_type = "t2.large"
  key_name = "${var.internal-keypair}"
  iam_instance_profile = "internal-instance"
  vpc_security_group_ids = [
    "${aws_security_group.default.id}"]
  subnet_id = "${aws_subnet.internal.id}"
  source_dest_check = false
  associate_public_ip_address = true
  user_data = "${replace("${data.template_file.client_cloud_config.rendered}", "REPLACE_HOSTNAME", "front-end")}"
  root_block_device {
    volume_type = "gp2"
    volume_size = 32
  }
  tags {
    Name = "${var.ansible-domain}-front-end"
    Role = "rancher-front-end,ad-client"
    Rig = "${var.ansible-domain}"
  }
}

# Jenkins private DNS record
resource "aws_route53_record" "front-end" {
  zone_id = "${aws_route53_zone.internal-zone.id}"
  name = "front-end"
  type = "A"
  ttl = "60"
  records = [
    "${aws_instance.front-end.private_ip}"]
}


output "aws-rancher-front-end-private-ip" {
  value = "${aws_instance.front-end.private_ip}"
}

output "aws-rancher-front-end-public-ip" {
  value = "${aws_instance.front-end.public_ip}"
}

## Front-End box
resource "aws_instance" "rancher-ha-db" {
  ami = "${coalesce(var.linux-ami, lookup(var.default-linux-ami, var.region))}"
  instance_type = "t2.large"
  key_name = "${var.internal-keypair}"
  iam_instance_profile = "internal-instance"
  vpc_security_group_ids = [
    "${aws_security_group.default.id}"]
  subnet_id = "${aws_subnet.internal.id}"
  source_dest_check = false
  associate_public_ip_address = false
  user_data = "${replace("${data.template_file.client_cloud_config.rendered}", "REPLACE_HOSTNAME", "rancher-ha-db")}"
  root_block_device {
    volume_type = "gp2"
    volume_size = 32
  }
  tags {
    Name = "${var.ansible-domain}-rancher-ha-db"
    Role = "rancher-ha-db,ad-client"
    Rig = "${var.ansible-domain}"
  }
}

# Jenkins private DNS record
resource "aws_route53_record" "rancher-ha-db" {
  zone_id = "${aws_route53_zone.internal-zone.id}"
  name = "rancher-ha-db"
  type = "A"
  ttl = "60"
  records = [
    "${aws_instance.front-end.private_ip}"]
}


output "aws-rancher-ha-db-private-ip" {
  value = "${aws_instance.rancher-ha-db.private_ip}"
}


## Rancher Server VM
resource "aws_instance" "rancher-server-master" {
  ami = "${coalesce(var.rancheros-ami, lookup(var.default-rancheros-ami, var.region))}"
  instance_type = "t2.2xlarge"
  key_name = "${var.internal-keypair}"
  iam_instance_profile = "internal-instance"
  vpc_security_group_ids = [
    "${aws_security_group.default.id}"]
  subnet_id = "${aws_subnet.internal.id}"
  source_dest_check = false
  associate_public_ip_address = false
  user_data = "${replace("${data.template_file.client_cloud_config.rendered}", "REPLACE_HOSTNAME", "rancher-server-master")}"
  root_block_device {
    volume_type = "gp2"
    volume_size = 80
  }
  tags {
    Name = "${var.ansible-domain}-rancher-server-master"
    Role = "rancher-server,rancher-base"
    Rig = "${var.ansible-domain}"
  }
}

## Rancher Server vars
output "aws-rancher-server-master-private-ip" {
  value = "${aws_instance.rancher-server-master.private_ip}"
}

## Rancher Server Route53
resource "aws_route53_record" "rancher-server-master" {
  zone_id = "${aws_route53_zone.internal-zone.id}"
  name = "rancher-server-master"
  type = "A"
  ttl = "60"
  records = [
    "${aws_instance.rancher-server-master.private_ip}"]
}

## Rancher Server Slave vm
resource "aws_instance" "rancher-server-slave" {
  ami = "${coalesce(var.rancheros-ami, lookup(var.default-rancheros-ami, var.region))}"
  instance_type = "t2.2xlarge"
  key_name = "${var.internal-keypair}"
  iam_instance_profile = "internal-instance"
  vpc_security_group_ids = [
    "${aws_security_group.default.id}"]
  subnet_id = "${aws_subnet.internal.id}"
  source_dest_check = false
  associate_public_ip_address = false
  user_data = "${replace("${data.template_file.client_cloud_config.rendered}", "REPLACE_HOSTNAME", "rancher-server-slave")}"
  root_block_device {
    volume_type = "gp2"
    volume_size = 80
  }
  tags {
    Name = "${var.ansible-domain}-rancher-server-slave"
    Role = "rancher-server-slave,rancher-base"
    Rig = "${var.ansible-domain}"
  }
}

## Rancher Server Slave vars
output "aws-rancher-server-slave-private-ip" {
  value = "${aws_instance.rancher-server-slave.private_ip}"
}

## Rancher Server Slave Route53
resource "aws_route53_record" "rancher-server-slave" {
  zone_id = "${aws_route53_zone.internal-zone.id}"
  name = "rancher-server-slave"
  type = "A"
  ttl = "60"
  records = [
    "${aws_instance.rancher-server-slave.private_ip}"]
}

## Rancher Infra 1 - Kubernetes
resource "aws_instance" "rancher-infra-1" {
  ami = "${coalesce(var.rancheros-ami, lookup(var.default-rancheros-ami, var.region))}"
  instance_type = "t2.xlarge"
  key_name = "${var.internal-keypair}"
  iam_instance_profile = "internal-instance"
  vpc_security_group_ids = [
    "${aws_security_group.default.id}"]
  subnet_id = "${aws_subnet.internal.id}"
  source_dest_check = false
  associate_public_ip_address = false
  user_data = "${replace("${data.template_file.client_cloud_config.rendered}", "REPLACE_HOSTNAME", "rancher-infra-1")}"
  root_block_device {
    volume_type = "gp2"
    volume_size = 80
  }
  tags {
    Name = "${var.ansible-domain}-rancher-infra-1"
    Role = "rancher-base,rancher-k8s-host"
    Rig = "${var.ansible-domain}"
  }
}

## Rancher Infra 1 - Kubernetes - vars
output "aws-rancher-infra-1-private-ip" {
  value = "${aws_instance.rancher-infra-1.private_ip}"
}

## Rancher Infra 1 - Kubernetes - Route53
resource "aws_route53_record" "rancher-infra-1" {
  zone_id = "${aws_route53_zone.internal-zone.id}"
  name = "rancher-infra-1"
  type = "A"
  ttl = "60"
  records = [
    "${aws_instance.rancher-infra-1.private_ip}"]
}

## Rancher Infra 1 - Kubernetes - Slave
resource "aws_instance" "rancher-infra-1-1" {
  ami = "${coalesce(var.rancheros-ami, lookup(var.default-rancheros-ami, var.region))}"
  instance_type = "t2.xlarge"
  key_name = "${var.internal-keypair}"
  iam_instance_profile = "internal-instance"
  vpc_security_group_ids = [
    "${aws_security_group.default.id}"]
  subnet_id = "${aws_subnet.internal.id}"
  source_dest_check = false
  associate_public_ip_address = false
  user_data = "${replace("${data.template_file.client_cloud_config.rendered}", "REPLACE_HOSTNAME", "rancher-infra-1-1")}"
  root_block_device {
    volume_type = "gp2"
    volume_size = 80
  }
  tags {
    Name = "${var.ansible-domain}-rancher-infra-1-1"
    Role = "rancher-base,rancher-k8s-host"
    Rig = "${var.ansible-domain}"
  }
}

## Rancher Infra 1 - Kubernetes - Slave - vars
output "aws-rancher-infra-1-1-private-ip" {
  value = "${aws_instance.rancher-infra-1-1.private_ip}"
}

## Rancher Infra 1 - Kubernetes - Slave - Route53
resource "aws_route53_record" "rancher-infra-1-1" {
  zone_id = "${aws_route53_zone.internal-zone.id}"
  name = "rancher-infra-1-1"
  type = "A"
  ttl = "60"
  records = [
    "${aws_instance.rancher-infra-1-1.private_ip}"]
}

## Rancher Infra 1 - Kubernetes - Slave
resource "aws_instance" "rancher-infra-1-2" {
  ami = "${coalesce(var.rancheros-ami, lookup(var.default-rancheros-ami, var.region))}"
  instance_type = "t2.xlarge"
  key_name = "${var.internal-keypair}"
  iam_instance_profile = "internal-instance"
  vpc_security_group_ids = [
    "${aws_security_group.default.id}"]
  subnet_id = "${aws_subnet.internal.id}"
  source_dest_check = false
  associate_public_ip_address = false
  user_data = "${replace("${data.template_file.client_cloud_config.rendered}", "REPLACE_HOSTNAME", "rancher-infra-1-2")}"
  root_block_device {
    volume_type = "gp2"
    volume_size = 80
  }
  tags {
    Name = "${var.ansible-domain}-rancher-infra-1-2"
    Role = "rancher-base,rancher-k8s-host"
    Rig = "${var.ansible-domain}"
  }
}

## Rancher Infra 1 - Kubernetes - Slave - vars
output "aws-rancher-infra-1-2-private-ip" {
  value = "${aws_instance.rancher-infra-1-2.private_ip}"
}

## Rancher Infra 1 - Kubernetes - Slave - Route53
resource "aws_route53_record" "rancher-infra-1-2" {
  zone_id = "${aws_route53_zone.internal-zone.id}"
  name = "rancher-infra-1-2"
  type = "A"
  ttl = "60"
  records = [
    "${aws_instance.rancher-infra-1-2.private_ip}"]
}

## Rancher Infra 2 - MESOS
resource "aws_instance" "rancher-infra-2" {
  ami = "${coalesce(var.rancheros-ami, lookup(var.default-rancheros-ami, var.region))}"
  instance_type = "m4.xlarge"
  key_name = "${var.internal-keypair}"
  iam_instance_profile = "internal-instance"
  vpc_security_group_ids = [
    "${aws_security_group.default.id}"]
  subnet_id = "${aws_subnet.internal.id}"
  source_dest_check = false
  associate_public_ip_address = false
  user_data = "${replace("${data.template_file.client_cloud_config.rendered}", "REPLACE_HOSTNAME", "rancher-infra-2")}"
  root_block_device {
    volume_type = "gp2"
    volume_size = 80
  }
  tags {
    Name = "${var.ansible-domain}-rancher-infra-2"
    Role = "rancher-base,rancher-mesos-host"
    Rig = "${var.ansible-domain}"
  }
}

## Rancher Infra 2 - MESOS - vars
output "aws-rancher-infra-2-private-ip" {
  value = "${aws_instance.rancher-infra-2.private_ip}"
}

## Rancher Infra 2 - MESOS - Route 53 Record
resource "aws_route53_record" "rancher-infra-2" {
  zone_id = "${aws_route53_zone.internal-zone.id}"
  name = "rancher-infra-2"
  type = "A"
  ttl = "60"
  records = [
    "${aws_instance.rancher-infra-2.private_ip}"]
}

## Rancher Infra 2 - MESOS - Slave
resource "aws_instance" "rancher-infra-2-1" {
  ami = "${coalesce(var.rancheros-ami, lookup(var.default-rancheros-ami, var.region))}"
  instance_type = "m4.xlarge"
  key_name = "${var.internal-keypair}"
  iam_instance_profile = "internal-instance"
  vpc_security_group_ids = [
    "${aws_security_group.default.id}"]
  subnet_id = "${aws_subnet.internal.id}"
  source_dest_check = false
  associate_public_ip_address = false
  user_data = "${replace("${data.template_file.client_cloud_config.rendered}", "REPLACE_HOSTNAME", "rancher-infra-2-1")}"
  root_block_device {
    volume_type = "gp2"
    volume_size = 80
  }
  tags {
    Name = "${var.ansible-domain}-rancher-infra-2-1"
    Role = "rancher-base,rancher-mesos-host"
    Rig = "${var.ansible-domain}"
  }
}

## Rancher Infra 2 - MESOS - Slave - vars
output "aws-rancher-infra-2-1-private-ip" {
  value = "${aws_instance.rancher-infra-2-1.private_ip}"
}

## Rancher Infra 2 - MESOS - Slave - Route 53 Record
resource "aws_route53_record" "rancher-infra-2-1" {
  zone_id = "${aws_route53_zone.internal-zone.id}"
  name = "rancher-infra-2-1"
  type = "A"
  ttl = "60"
  records = [
    "${aws_instance.rancher-infra-2-1.private_ip}"]
}

## Rancher Infra 2 - MESOS - Slave
resource "aws_instance" "rancher-infra-2-2" {
  ami = "${coalesce(var.rancheros-ami, lookup(var.default-rancheros-ami, var.region))}"
  instance_type = "m4.xlarge"
  key_name = "${var.internal-keypair}"
  iam_instance_profile = "internal-instance"
  vpc_security_group_ids = [
    "${aws_security_group.default.id}"]
  subnet_id = "${aws_subnet.internal.id}"
  source_dest_check = false
  associate_public_ip_address = false
  user_data = "${replace("${data.template_file.client_cloud_config.rendered}", "REPLACE_HOSTNAME", "rancher-infra-2-2")}"
  root_block_device {
    volume_type = "gp2"
    volume_size = 80
  }
  tags {
    Name = "${var.ansible-domain}-rancher-infra-2-2"
    Role = "rancher-base,rancher-mesos-host"
    Rig = "${var.ansible-domain}"
  }
}

## Rancher Infra 2 - MESOS - Slave - vars
output "aws-rancher-infra-2-2-private-ip" {
  value = "${aws_instance.rancher-infra-2-2.private_ip}"
}

## Rancher Infra 2 - MESOS - Slave - Route 53 Record
resource "aws_route53_record" "rancher-infra-2-2" {
  zone_id = "${aws_route53_zone.internal-zone.id}"
  name = "rancher-infra-2-2"
  type = "A"
  ttl = "60"
  records = [
    "${aws_instance.rancher-infra-2-2.private_ip}"]
}

## Rancher Infra 3 - Potainer Swarm Nodes
resource "aws_instance" "rancher-infra-3" {
  ami = "${coalesce(var.rancheros-ami, lookup(var.default-rancheros-ami, var.region))}"
  instance_type = "m4.xlarge"
  key_name = "${var.internal-keypair}"
  iam_instance_profile = "internal-instance"
  vpc_security_group_ids = [
    "${aws_security_group.default.id}"]
  subnet_id = "${aws_subnet.internal.id}"
  source_dest_check = false
  associate_public_ip_address = false
  user_data = "${replace("${data.template_file.client_cloud_config.rendered}", "REPLACE_HOSTNAME", "rancher-infra-3")}"
  root_block_device {
    volume_type = "gp2"
    volume_size = 80
  }
  tags {
    Name = "${var.ansible-domain}-rancher-infra-3"
    Role = "rancher-base,rancher-portainer-host"
    Rig = "${var.ansible-domain}"
  }
}

## Rancher Infra 3 - Potainer Swarm Nodes - vars
output "aws-rancher-infra-3-private-ip" {
  value = "${aws_instance.rancher-infra-3.private_ip}"
}

## Rancher Infra 3 - Potainer Swarm Nodes - Route 53 Record
resource "aws_route53_record" "rancher-infra-3" {
  zone_id = "${aws_route53_zone.internal-zone.id}"
  name = "rancher-infra-3"
  type = "A"
  ttl = "60"
  records = [
    "${aws_instance.rancher-infra-3.private_ip}"]
}

## Rancher Infra 3 - Potainer Swarm Nodes - Slave
resource "aws_instance" "rancher-infra-3-1" {
  ami = "${coalesce(var.rancheros-ami, lookup(var.default-rancheros-ami, var.region))}"
  instance_type = "m4.xlarge"
  key_name = "${var.internal-keypair}"
  iam_instance_profile = "internal-instance"
  vpc_security_group_ids = [
    "${aws_security_group.default.id}"]
  subnet_id = "${aws_subnet.internal.id}"
  source_dest_check = false
  associate_public_ip_address = false
  user_data = "${replace("${data.template_file.client_cloud_config.rendered}", "REPLACE_HOSTNAME", "rancher-infra-3-1")}"
  root_block_device {
    volume_type = "gp2"
    volume_size = 80
  }
  tags {
    Name = "${var.ansible-domain}-rancher-infra-3-1"
    Role = "rancher-base,rancher-portainer-host"
    Rig = "${var.ansible-domain}"
  }
}

## Rancher Infra 3 - Potainer Swarm Nodes - Slave - vars
output "aws-rancher-infra-3-1-private-ip" {
  value = "${aws_instance.rancher-infra-3-1.private_ip}"
}

## Rancher Infra 3 - Potainer Swarm Nodes - Slave - Route 53 Record
resource "aws_route53_record" "rancher-infra-3-1" {
  zone_id = "${aws_route53_zone.internal-zone.id}"
  name = "rancher-infra-3-1"
  type = "A"
  ttl = "60"
  records = [
    "${aws_instance.rancher-infra-3-1.private_ip}"]
}

## Rancher Infra 3 - Potainer Swarm Nodes - Slave
resource "aws_instance" "rancher-infra-3-2" {
  ami = "${coalesce(var.rancheros-ami, lookup(var.default-rancheros-ami, var.region))}"
  instance_type = "m4.xlarge"
  key_name = "${var.internal-keypair}"
  iam_instance_profile = "internal-instance"
  vpc_security_group_ids = [
    "${aws_security_group.default.id}"]
  subnet_id = "${aws_subnet.internal.id}"
  source_dest_check = false
  associate_public_ip_address = false
  user_data = "${replace("${data.template_file.client_cloud_config.rendered}", "REPLACE_HOSTNAME", "rancher-infra-3-2")}"
  root_block_device {
    volume_type = "gp2"
    volume_size = 80
  }
  tags {
    Name = "${var.ansible-domain}-rancher-infra-3-2"
    Role = "rancher-base,rancher-portainer-host"
    Rig = "${var.ansible-domain}"
  }
}

## Rancher Infra 3 - Potainer Swarm Nodes - Slave - vars
output "aws-rancher-infra-3-1-private-ip" {
  value = "${aws_instance.rancher-infra-3-1.private_ip}"
}

## Rancher Infra 3 - Potainer Swarm Nodes - Slave - Route 53 Record
resource "aws_route53_record" "rancher-infra-3-2" {
  zone_id = "${aws_route53_zone.internal-zone.id}"
  name = "rancher-infra-3-2"
  type = "A"
  ttl = "60"
  records = [
    "${aws_instance.rancher-infra-3-2.private_ip}"]
}

## Rancher Application Node 1 - General Purpose
resource "aws_instance" "rancher-app-1" {
  ami = "${coalesce(var.rancheros-ami, lookup(var.default-rancheros-ami, var.region))}"
  instance_type = "t2.xlarge"
  key_name = "${var.internal-keypair}"
  iam_instance_profile = "internal-instance"
  vpc_security_group_ids = [
    "${aws_security_group.default.id}"]
  subnet_id = "${aws_subnet.internal.id}"
  source_dest_check = false
  associate_public_ip_address = false
  user_data = "${replace("${data.template_file.client_cloud_config.rendered}", "REPLACE_HOSTNAME", "rancher-app-1")}"
  root_block_device {
    volume_type = "gp2"
    volume_size = 80
  }
  tags {
    Name = "${var.ansible-domain}-rancher-app-1"
    Role = "rancher-base,rancher-env1-host"
    Rig = "${var.ansible-domain}"
  }
}

## Rancher Application Node 1 - General Purpose - vars
output "aws-rancher-app-1-private-ip" {
  value = "${aws_instance.rancher-app-1.private_ip}"
}

## Rancher Application Node 1 - General Purpose - Route 53 Record
resource "aws_route53_record" "rancher-app-1" {
  zone_id = "${aws_route53_zone.internal-zone.id}"
  name = "rancher-app-1"
  type = "A"
  ttl = "60"
  records = [
    "${aws_instance.rancher-app-1.private_ip}"]
}

## Rancher Application Node 2 - General Purpose
resource "aws_instance" "rancher-app-2" {
  ami = "${coalesce(var.rancheros-ami, lookup(var.default-rancheros-ami, var.region))}"
  instance_type = "t2.xlarge"
  key_name = "${var.internal-keypair}"
  iam_instance_profile = "internal-instance"
  vpc_security_group_ids = [
    "${aws_security_group.default.id}"]
  subnet_id = "${aws_subnet.internal.id}"
  source_dest_check = false
  associate_public_ip_address = false
  user_data = "${replace("${data.template_file.client_cloud_config.rendered}", "REPLACE_HOSTNAME", "rancher-app-2")}"
  root_block_device {
    volume_type = "gp2"
    volume_size = 80
  }
  tags {
    Name = "${var.ansible-domain}-rancher-app-2"
    Role = "rancher-base,rancher-env2-host"
    Rig = "${var.ansible-domain}"
  }
}

## Rancher Application Node 2 - General Purpose - vars
output "aws-rancher-app-2-private-ip" {
  value = "${aws_instance.rancher-app-2.private_ip}"
}

## Rancher Application Node 2 - General Purpose - Route 53 Record
resource "aws_route53_record" "rancher-app-2" {
  zone_id = "${aws_route53_zone.internal-zone.id}"
  name = "rancher-app-2"
  type = "A"
  ttl = "60"
  records = [
    "${aws_instance.rancher-app-2.private_ip}"]
}

## Rancher Application Node 3 - General Purpose
resource "aws_instance" "rancher-app-3" {
  ami = "${coalesce(var.rancheros-ami, lookup(var.default-rancheros-ami, var.region))}"
  instance_type = "t2.xlarge"
  key_name = "${var.internal-keypair}"
  iam_instance_profile = "internal-instance"
  vpc_security_group_ids = [
    "${aws_security_group.default.id}"]
  subnet_id = "${aws_subnet.internal.id}"
  source_dest_check = false
  associate_public_ip_address = false
  user_data = "${replace("${data.template_file.client_cloud_config.rendered}", "REPLACE_HOSTNAME", "rancher-app-3")}"
  root_block_device {
    volume_type = "gp2"
    volume_size = 80
  }
  tags {
    Name = "${var.ansible-domain}-rancher-app-3"
    Role = "rancher-base,rancher-env3-host"
    Rig = "${var.ansible-domain}"
  }
}

## Rancher Application Node 3 - General Purpose - vars
output "aws-rancher-app-3-private-ip" {
  value = "${aws_instance.rancher-app-3.private_ip}"
}

## Rancher Application Node 3 - General Purpose - Route 53 Record
resource "aws_route53_record" "rancher-app-3" {
  zone_id = "${aws_route53_zone.internal-zone.id}"
  name = "rancher-app-3"
  type = "A"
  ttl = "60"
  records = [
    "${aws_instance.rancher-app-3.private_ip}"]
}

## windows server box to manage active directory
resource "aws_instance" "ad-admin" {
  ami = "${coalesce(var.windows-ami, lookup(var.default-windows-ami, var.region))}"
  instance_type = "t2.micro"
  key_name = "${var.internal-keypair}"
  vpc_security_group_ids = [
    "${aws_security_group.default.id}"]
  subnet_id = "${aws_subnet.internal.id}"
  source_dest_check = false
  associate_public_ip_address = false
  user_data = "${replace("${data.template_file.client_cloud_config.rendered}", "REPLACE_HOSTNAME", "ad-admin")}"
  tags {
    Name = "${var.ansible-domain}-ad-admin"
    Role = "windows"
    Rig = "${var.ansible-domain}"
  }
}

output "aws-admin-private-ip" {
  value = "${aws_instance.ad-admin.private_ip}"
}

# windows server box  private DNS record
resource "aws_route53_record" "ad-admin" {
  zone_id = "${aws_route53_zone.internal-zone.id}"
  name = "ad-admin"
  type = "A"
  ttl = "60"
  records = [
    "${aws_instance.ad-admin.private_ip}"]
}
