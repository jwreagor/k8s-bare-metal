resource "triton_machine" "worker" {
  count = 3
  name  = "worker${format("%02d", count.index)}"

  depends_on = [
    "triton_machine.controller"
  ]

  package = "${var.worker_package}"
  image = "${var.worker_image}"

  nic {
    network = "${var.private_network}"
  }

  tags {
    hostname = "worker${format("%02d", count.index)}"
    role = "worker"
  }
}

// -----------------------------------------------------------------------------

output "kubernetes_worker_ips" {
  value = "${join(",", triton_machine.worker.*.ips)}"
}
