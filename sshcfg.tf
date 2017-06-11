# generate ./ssh.cfg for ansible usage
data "template_file" "ssh_cfg" {
    template = "${file("${path.module}/template/ssh.cfg")}"
    depends_on = [
      "triton_machine.etcd",
      "triton_machine.apiserver",
      "triton_machine.scheduler",
      "triton_machine.controller_manager",
      "triton_machine.worker",
      "triton_machine.bastion"
    ]
    vars {
      user = "${var.default_instance_user}"

      etcd0_ip = "${triton_machine.etcd.0.primaryip}"
      etcd1_ip = "${triton_machine.etcd.1.primaryip}"
      etcd2_ip = "${triton_machine.etcd.2.primaryip}"
      apiserver_ip = "${triton_machine.apiserver.0.primaryip}"
      scheduler_ip = "${triton_machine.scheduler.0.primaryip}"
      controller_manager_ip = "${triton_machine.controller_manager.0.primaryip}"
      worker0_ip = "${triton_machine.worker.0.primaryip}"
      bastion_ip = "${triton_machine.bastion.0.primaryip}"
    }
}
resource "null_resource" "ssh_cfg" {
  triggers {
    template_rendered = "${data.template_file.ssh_cfg.rendered}"
  }
  provisioner "local-exec" {
    command = "echo '${data.template_file.ssh_cfg.rendered}' > ../ssh.cfg"
  }
}
