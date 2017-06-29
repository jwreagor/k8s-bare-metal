// kube-controller-manager.sh --------------------------------------------------

data "template_file" "start_controller_manager" {
  template   = "${file("${path.module}/scripts/kube-controller-manager.sh")}"
  depends_on = [
    "triton_machine.controller",
  ]

  vars {
    master_ip = "${triton_machine.controller.0.primaryip}"
  }
}

resource "local_file" "start_controller_manager" {
  content  = "${data.template_file.start_controller_manager.rendered}"
  filename = "${path.module}/output/kube-controller-manager.sh"
}

// kube-apiserver.sh -----------------------------------------------------------

data "template_file" "start_apiserver" {
  template   = "${file("${path.module}/scripts/kube-apiserver.sh")}"
  depends_on = [
    "triton_machine.controller",
  ]

  vars {
    controller_count = "${length(triton_machine.controller.*.primaryip)}"
    etcd_servers     = "${join(",", formatlist("http://%s:2379", list(var.etcd1_ip, var.etcd2_ip, var.etcd3_ip)))}"
  }
}

resource "local_file" "start_apiserver" {
  content   = "${data.template_file.start_apiserver.rendered}"
  filename  = "${path.module}/output/kube-apiserver.sh"
}

// kubeconfig ------------------------------------------------------------------

data "template_file" "kubeconfig" {
  template   = "${file("${path.module}/templates/kubeconfig.tpl")}"
  depends_on = [
    "triton_machine.worker",
  ]

  vars {
    secret_token = "${var.secret_token}"
    master_ip    = "${triton_machine.controller.0.primaryip}"
  }
}

resource "local_file" "kubeconfig" {
  content  = "${data.template_file.kubeconfig.rendered}"
  filename = "${path.module}/output/kubeconfig"
}

// kubelet.sh ------------------------------------------------------------------

data "template_file" "start_kubelet" {
  template   = "${file("${path.module}/scripts/kubelet.sh")}"
  depends_on = [
    "triton_machine.worker",
  ]

  vars {
    master_ip = "${triton_machine.controller.0.primaryip}"
  }
}

resource "local_file" "start_kubelet" {
  content  = "${data.template_file.start_kubelet.rendered}"
  filename = "${path.module}/output/kubelet.sh"
}

// kube-proxy.sh ---------------------------------------------------------------

data "template_file" "start_kube_proxy" {
  template   = "${file("${path.module}/scripts/kube-proxy.sh")}"
  depends_on = [
    "triton_machine.worker",
  ]

  vars {
    master_ip = "${triton_machine.controller.0.primaryip}"
  }
}

resource "local_file" "start_kube_proxy" {
  content  = "${data.template_file.start_kube_proxy.rendered}"
  filename = "${path.module}/output/kube-proxy.sh"
}

// token.csv -------------------------------------------------------------------

data "template_file" "token_csv" {
  template   = "${file("${path.module}/templates/token.csv.tpl")}"
  depends_on = [
    "triton_machine.controller",
  ]

  vars {
    secret_token = "${var.secret_token}"
  }
}

resource "local_file" "token_csv" {
  content  = "${data.template_file.token_csv.rendered}"
  filename = "${path.module}/output/token.csv"
}

// ssh.config ------------------------------------------------------------------

data "template_file" "ssh_config" {
  template = "${file("${path.module}/templates/ssh.config.tpl")}"

  vars {
    bastion_ip    = "${var.bastion_host}"
    identity_file = "${var.triton_key_path}"
  }
}

resource "local_file" "ssh_config" {
  content   = "${data.template_file.ssh_config.rendered}"
  filename  = "${path.module}/output/ssh.config"
}

// setup-kubectl.sh ------------------------------------------------------------

data "template_file" "setup_kubectl" {
  template   = "${file("${path.module}/scripts/setup-kubectl.sh")}"
  depends_on = [
    "triton_machine.controller",
  ]

  vars {
    cluster_name = "${var.cluster_name}"
    secret_token = "${var.secret_token}"
    master_ip    = "${triton_machine.controller.0.primaryip}"
  }
}

resource "local_file" "setup_kubectl" {
  content  = "${data.template_file.setup_kubectl.rendered}"
  filename = "${path.module}/output/setup-kubectl.sh"
}

// ansible-inventory -----------------------------------------------------------

data "template_file" "controller_ansible" {
  count    = "${triton_machine.controller.count}"
  template = "${file("${path.module}/templates/hostname.tpl")}"

  depends_on = [
    "triton_machine.controller",
  ]

  vars {
    index = "${count.index + 1}"
    name  = "controller${format("%02d", count.index)}"
    extra = " ansible_host=${element(triton_machine.controller.*.primaryip, count.index)}"
  }
}

data "template_file" "worker_ansible" {
  count    = "${triton_machine.worker.count}"
  template = "${file("${path.module}/templates/hostuser.tpl")}"

  depends_on = [
    "triton_machine.worker",
  ]

  vars {
    index = "${count.index + 1}"
    name  = "worker${format("%02d", count.index)}"
    extra = " ansible_host=${element(triton_machine.worker.*.primaryip, count.index)}"
  }
}

data "template_file" "ansible_inventory" {
  template = "${file("${path.module}/templates/ansible_inventory.tpl")}"

  vars {
    bastion_ip       = "${var.bastion_host}"
    controller_hosts = "${join("\n", data.template_file.controller_ansible.*.rendered)}"
    worker_hosts     = "${join("\n", data.template_file.worker_ansible.*.rendered)}"
  }
}

resource "local_file" "ansible_inventory" {
  content  = "${data.template_file.ansible_inventory.rendered}"
  filename = "${path.module}/output/ansible_inventory"
}
