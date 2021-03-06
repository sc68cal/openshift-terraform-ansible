variable "openstack_keypair" {}
variable "num_nodes" { default = "2"}
variable "master_image_id" {}
variable "master_instance_size" {}
variable "node_image_id" {}
variable "node_instance_size" {}
variable "ssh_user" { default = "centos" }
variable "network_name" {}
variable "denis_access_key" {}
variable "denis_secret_key" {}
variable "denis_host" {
  default = "https://api.denis.comcast.net:9443"
}
variable "denis_fqdn" {}

variable "zone_id" {
  # Owned by scolli572
  default = "553ce6a6-e7af-4877-b609-c02b46ff7b48"
}

provider "denis" {
  access_key = "${var.denis_access_key}"
  secret_key = "${var.denis_secret_key}"
  host       = "${var.denis_host}"
}



resource "openstack_networking_secgroup_v2" "os3-sec-group" {
  name = "os3-sec-group"
  description = "Defines well-known ports used for OS3 Master and Node deployments"
}
resource "openstack_networking_secgroup_rule_v2" "port_22" {
  direction = "ingress"
  ethertype = "IPv4"
  port_range_min = 22
  port_range_max = 22
  protocol = "tcp"
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.os3-sec-group.id}"
}

resource "openstack_networking_secgroup_rule_v2" "port_22_v6" {
  direction = "ingress"
  ethertype = "IPv6"
  port_range_min = 22
  port_range_max = 22
  protocol = "tcp"
  remote_ip_prefix = "::/0"
  security_group_id = "${openstack_networking_secgroup_v2.os3-sec-group.id}"
}

resource "openstack_networking_secgroup_rule_v2" "port_53" {
  direction = "ingress"
  ethertype = "IPv4"
  port_range_min = 53
  port_range_max = 53
  protocol = "tcp"
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.os3-sec-group.id}"

}
resource "openstack_networking_secgroup_rule_v2" "port_80" {
  direction = "ingress"
  ethertype = "IPv4"
  port_range_min = 80
  port_range_max = 80
  protocol = "tcp"
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.os3-sec-group.id}"

}
resource "openstack_networking_secgroup_rule_v2" "port_443" {
  direction = "ingress"
  ethertype = "IPv4"
  port_range_min = 443
  port_range_max = 443
  protocol = "tcp"
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.os3-sec-group.id}"

}
resource "openstack_networking_secgroup_rule_v2" "port_1936" {
  direction = "ingress"
  ethertype = "IPv4"
  port_range_min = 1936
  port_range_max = 1936
  protocol = "tcp"
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.os3-sec-group.id}"

}
resource "openstack_networking_secgroup_rule_v2" "port_4001" {
  direction = "ingress"
  ethertype = "IPv4"
  port_range_min = 4001
  port_range_max = 4001
  protocol = "tcp"
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.os3-sec-group.id}"

}
resource "openstack_networking_secgroup_rule_v2" "port_7001" {
  direction = "ingress"
  ethertype = "IPv4"
  port_range_min = 7001
  port_range_max = 7001
  protocol = "tcp"
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.os3-sec-group.id}"

}
resource "openstack_networking_secgroup_rule_v2" "port_8443"{
  direction = "ingress"
  ethertype = "IPv4"
  port_range_min = 8443
  port_range_max = 8444
  protocol = "tcp"
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.os3-sec-group.id}"

}
resource "openstack_networking_secgroup_rule_v2" "port_10250" {
  direction = "ingress"
  ethertype = "IPv4"
  port_range_min = 10250
  port_range_max = 10250
  protocol = "tcp"
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.os3-sec-group.id}"

}

resource "openstack_networking_secgroup_rule_v2" "port_4789" {
  direction = "ingress"
  ethertype = "IPv4"
  port_range_min = 4789
  port_range_max = 4789
  protocol = "udp"
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.os3-sec-group.id}"

}
resource "openstack_networking_secgroup_rule_v2" "port_24224" {
  direction = "ingress"
  ethertype = "IPv4"
  port_range_min = 24224
  port_range_max = 24224
  protocol = "udp"
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.os3-sec-group.id}"

}

resource "openstack_blockstorage_volume_v1" "master-docker-vol" {
  name = "mastervol"
  size = 25
}

resource "openstack_blockstorage_volume_v1" "node-docker-vol" {
  count = "${var.num_nodes}"
  name = "node-docker-vol${format("%02d", count.index)}"
  size = 25
}

resource "openstack_compute_instance_v2" "ose-master" {
  name = "ose-master.${var.denis_fqdn}"
  image_id = "${var.master_image_id}"
  flavor_name = "${var.master_instance_size}"
  key_pair = "${var.openstack_keypair}"
  security_groups = ["default", "os3-sec-group"]
  metadata {
    ansible_user = "${var.ssh_user}"
    fqdn = "${var.denis_fqdn}"
  }

  network {
    name = "${var.network_name}"
  }

  depends_on = [ "openstack_networking_secgroup_v2.os3-sec-group"]
}

resource "denis_record_set" "ose-master-record" {
  name = "ose-master"
  zone_id = "${var.zone_id}"
  type = "A"
  ttl = 300
  record_addresses =
["${openstack_compute_instance_v2.ose-master.access_ip_v4}"]

}

resource "openstack_compute_volume_attach_v2" "ose-master-attach" {
  instance_id = "${openstack_compute_instance_v2.ose-master.id}"
  volume_id = "${openstack_blockstorage_volume_v1.master-docker-vol.id}"
}

resource "openstack_compute_instance_v2" "ose-node" {
  count = "${var.num_nodes}"
  name = "ose-node-${format("%02d", count.index)}.${var.denis_fqdn}"
  image_id = "${var.node_image_id}"
  flavor_name = "${var.node_instance_size}"
  key_pair = "${var.openstack_keypair}"
  security_groups = ["default", "os3-sec-group"]
  metadata {
    ansible_user = "${var.ssh_user}"
    fqdn = "${var.denis_fqdn}"
  }
  network {
    name = "${var.network_name}"
  }
  depends_on = [ "openstack_networking_secgroup_v2.os3-sec-group"]

}

resource "openstack_compute_volume_attach_v2" "ose-node-attach" {
  count = "${var.num_nodes}"
  instance_id = "${element(openstack_compute_instance_v2.ose-node.*.id, count.index)}"
  volume_id = "${element(openstack_blockstorage_volume_v1.node-docker-vol.*.id, count.index)}"
}

resource "denis_record_set" "ose-node-record" {
  count = "${var.num_nodes}"
  name = "ose-node-${format("%02d", count.index)}"
  zone_id = "${var.zone_id}"
  type = "A"
  ttl = 300
  record_addresses =
["${element(openstack_compute_instance_v2.ose-node.*.access_ip_v4,
count.index)}"]
}
