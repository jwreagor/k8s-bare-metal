resource "triton_machine" "controller" {
  iter = "${format("%02d", count.index + 1)}"
  count = 0
  name  = "controller${format("%02d", count.index + 1)}"
  package = "${var.controller_package}"
  image = "${var.controller_image}"

  tags {
    name  = "controller${format("%02d", count.index + 1)}"
    hostname  = "controller${format("%02d", count.index + 1)}"
    ansibleFilter = "${var.ansibleFilter}"
    ansibleNodeType = "controller"
    ansibleNodeName = "controller${format("%02d", count.index + 1)}"
  }
}

output "kubernetes_controller_ips" {
  value = "${join(",", triton_machine.controller.*.ips)}"
}
