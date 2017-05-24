resource "aws_s3_bucket" "rancheros-backup" {
  bucket = "rancheros-${replace(var.ansible-domain, ".", "-")}"
  acl = "private"
  region = "${var.region}"
  force_destroy= true
}
resource "aws_s3_bucket" "rancheros-docker-registry" {
  bucket = "docker-registry-${replace(var.ansible-domain, ".", "-")}"
  acl = "private"
  region = "${var.region}"
  force_destroy= true
}
