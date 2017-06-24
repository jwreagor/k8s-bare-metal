// start-kube-controller-manager.sh --------------------------------------------

data "template_file" "start_controller_manager" {
  template = "${file("${path.module}/scripts/start-kube-controller-manager.sh")}"
  depends_on = [
    "triton_machine.controller",
  ]

  vars {
    master_ip = "${triton_machine.controller.0.primaryip}"
  }
}

resource "local_file" "start_controller_manager" {
  content     = "${data.template_file.start_controller_manager.rendered}"
  filename = "${path.module}/output/start-kube-controller-manager.sh"
}

// start-kube-apiserver.sh -----------------------------------------------------

data "template_file" "start_apiserver" {
  template = "${file("${path.module}/scripts/start-kube-apiserver.sh")}"
  depends_on = [
    "triton_machine.controller",
  ]

  vars {
    controller_count = "${length(triton_machine.controller.*.primaryip)}"
    etcd_servers = "${join(",", formatlist("http://%s:2379", list(var.etcd1_ip, var.etcd2_ip, var.etcd3_ip)))}"
  }
}

resource "local_file" "start_apiserver" {
  content   = "${data.template_file.start_apiserver.rendered}"
  filename  = "${path.module}/output/start-kube-apiserver.sh"
}
