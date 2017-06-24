resource "triton_machine" "controller" {
  count = 2
  name  = "controller${format("%02d", count.index)}"

  package = "${var.controller_package}"
  image   = "${var.controller_image}"

  nic {
    network = "${var.private_network}"
  }

  tags {
    hostname = "controller${format("%02d", count.index)}"
    role     = "controller"
  }
}

// -----------------------------------------------------------------------------

output "kubernetes_master_ip" {
  value = "${join(",", triton_machine.controller.0.primaryip)}"
}

output "kubernetes_controller_ips" {
  value = "${join(",", triton_machine.controller.*.ips)}"
}
