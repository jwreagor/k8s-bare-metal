resource "triton_machine" "worker" {
  count = 1
  name  = "worker${format("%02d", count.index + 1)}"
  package = "${var.worker_package}"
  image = "${var.worker_image}"

  tags {
    name  = "worker${format("%02d", count.index + 1)}"
    hostname  = "worker${format("%02d", count.index + 1)}"
    ansibleFilter = "${var.ansibleFilter}"
    ansibleNodeType = "worker"
    ansibleNodeName = "worker${format("%02d", count.index + 1)}"
  }
}

output "kubernetes_worker_ips" {
  value = "${join(",", triton_machine.worker.*.ips)}"
}
