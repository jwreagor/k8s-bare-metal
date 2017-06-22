resource "triton_machine" "controller" {
  count = 1
  name  = "controller${format("%02d", count.index + 1)}"

  package = "${var.controller_package}"
  image = "${var.controller_image}"

  nic {
    network = "${var.private_network_id}"
  }

  tags {
    hostname  = "controller${format("%02d", count.index + 1)}"
  }
}

resource "triton_machine" "worker" {
  count = 1
  name  = "worker${format("%02d", count.index + 1)}"

  package = "${var.worker_package}"
  image = "${var.worker_image}"

  nic {
    network = "${var.private_network_id}"
  }

  tags {
    hostname  = "worker${format("%02d", count.index + 1)}"
  }
}

resource "triton_machine" "edge_worker" {
  count = 1
  name  = "edge_worker${format("%02d", count.index + 1)}"

  package = "${var.worker_package}"
  image = "${var.worker_image}"

  nic {
    network = "${var.private_network_id}"
  }
  nic {
    network = "${var.public_network_id}"
  }

  tags {
    hostname  = "edge_worker${format("%02d", count.index + 1)}"
  }
}

output "kubernetes_controller_ips" {
  value = "${join(",", triton_machine.controller.*.ips)}"
}

output "kubernetes_worker_ips" {
  value = "${join(",", triton_machine.worker.*.ips)}"
}

output "kubernetes_edge_worker_ips" {
  value = "${join(",", triton_machine.edge_worker.*.ips)}"
}
