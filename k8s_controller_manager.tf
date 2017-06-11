resource "triton_machine" "controller_manager" {
  count = 1
  name  = "controller_manager${format("%02d", count.index + 1)}"
  package = "${var.controller_package}"
  image = "${var.controller_image}"

  tags {
    name  = "controller_manager${format("%02d", count.index + 1)}"
    hostname  = "controller_manager${format("%02d", count.index + 1)}"
    ansibleFilter = "${var.ansibleFilter}"
    ansibleNodeType = "controller_manager"
    ansibleNodeName = "controller_manager${format("%02d", count.index + 1)}"
  }
}

output "kubernetes_controller_manager_ips" {
  value = "${join(",", triton_machine.controller_manager.*.ips)}"
}
