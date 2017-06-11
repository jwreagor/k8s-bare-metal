resource "triton_machine" "apiserver" {
  count = 1
  name  = "apiserver${format("%02d", count.index + 1)}"
  package = "${var.controller_package}"
  image = "${var.controller_image}"

  tags {
    name  = "apiserver${format("%02d", count.index + 1)}"
    hostname  = "apiserver${format("%02d", count.index + 1)}"
    ansibleFilter = "${var.ansibleFilter}"
    ansibleNodeType = "apiserver"
    ansibleNodeName = "apiserver${format("%02d", count.index + 1)}"
  }
}

output "kubernetes_apiserver_ips" {
  value = "${join(",", triton_machine.apiserver.*.ips)}"
}
