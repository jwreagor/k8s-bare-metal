resource "triton_machine" "scheduler" {
  count = 1
  name  = "scheduler${format("%02d", count.index + 1)}"
  package = "${var.controller_package}"
  image = "${var.controller_image}"

  tags {
    name  = "scheduler${format("%02d", count.index + 1)}"
    hostname  = "scheduler${format("%02d", count.index + 1)}"
    ansibleFilter = "${var.ansibleFilter}"
    ansibleNodeType = "scheduler"
    ansibleNodeName = "scheduler${format("%02d", count.index + 1)}"
  }
}

output "kubernetes_scheduler_ips" {
  value = "${join(",", triton_machine.scheduler.*.ips)}"
}
