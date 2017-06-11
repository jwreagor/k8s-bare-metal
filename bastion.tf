resource "triton_machine" "bastion" {
  count = 1
  name  = "bastion"
  package = "${var.bastion_package}"
  image = "${var.bastion_image}"

  tags {
    name  = "bastion"
    hostname  = "bastion"
    ansibleFilter = "${var.ansibleFilter}"
    ansibleNodeType = "bastion"
    ansibleNodeName = "bastion"
  }
}

output "kubernetes_bastion_ips" {
  value = "${join(",", triton_machine.bastion.0.ips)}"
}
