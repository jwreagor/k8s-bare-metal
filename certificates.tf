# Generate certificates
data "template_file" "certificates" {
    template = "${file("${path.module}/template/kubernetes-csr.json")}"
    depends_on = [
      "triton_machine.etcd",
      "triton_machine.apiserver",
      "triton_machine.scheduler",
      "triton_machine.controller_manager",
      "triton_machine.worker"
    ]

    vars {
      # variables must be primitives, neither lists nor maps
      etcd0_ip = "${join(",", triton_machine.etcd.0.ips)}"
      etcd1_ip = "${join(",", triton_machine.etcd.1.ips)}"
      etcd2_ip = "${join(",", triton_machine.etcd.2.ips)}"
      apiserver0_ip = "${join(",", triton_machine.apiserver.0.ips)}"
      scheduler0_ip = "${join(",", triton_machine.scheduler.0.ips)}"
      controller_manager2_ip = "${join(",", triton_machine.controller_manager.0.ips)}"
      worker0_ip = "${join(",", triton_machine.worker.0.ips)}"
    }
}
resource "null_resource" "certificates" {
  triggers {
    template_rendered = "${data.template_file.certificates.rendered}"
  }
  provisioner "local-exec" {
    command = "echo '${data.template_file.certificates.rendered}' > ../cert/kubernetes-csr.json"
  }
  provisioner "local-exec" {
    command = "cd ../cert; cfssl gencert -initca ca-csr.json | cfssljson -bare ca; cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes kubernetes-csr.json | cfssljson -bare kubernetes"
  }
}
