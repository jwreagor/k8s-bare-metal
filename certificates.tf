# Generate certificates
data "template_file" "certificates" {
    template = "${file("${path.module}/templates/kubernetes-csr.json")}"
    depends_on = [
      "triton_machine.controller",
      "triton_machine.worker",
      "triton_machine.edge_worker"
    ]

    vars {
      # variables must be primitives, neither lists nor maps
      controller0_ip = "${triton_machine.controller.0.primaryip}"
      worker0_ip = "${triton_machine.worker.0.primaryip}"
      edge_worker0_ip = "${triton_machine.edge_worker.0.primaryip}"
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
