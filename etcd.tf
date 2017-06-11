resource "triton_machine" "etcd" {
  count = 3
  name  = "etcd${format("%02d", count.index + 1)}"
  package = "${var.etcd_package}"
  image = "${var.etcd_image}"

  tags {
    name  = "etcd${format("%02d", count.index + 1)}"
    hostname  = "etcd${format("%02d", count.index + 1)}"
    ansibleFilter = "${var.ansibleFilter}"
    ansibleNodeType = "etcd"
    ansibleNodeName = "etcd${format("%02d", count.index + 1)}"
  }
}

output "kubernetes_etcd_ips" {
  value = "${join(",", triton_machine.etcd.*.ips)}"
}
