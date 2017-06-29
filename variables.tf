variable triton_account {
  description = "The same SDC_ACCOUNT used by the Triton CLI"
}

variable triton_key_id {
  description = "The same SDC_KEY_ID used by the Triton CLI"
}

variable triton_url {
  description = "The same SDC_URL used by the Triton CLI"
}

variable triton_key_path {
  description = "Path to the SSH private key used by Triton"
}

variable cluster_name {
  description = "Name your kubernetes cluster, setup through kubectl"
  default = "kubernetes-the-hard-way"
}

# head /dev/urandom | base32 | head -c 8
variable secret_token {
  description = "Secret token used by Kubernetes for securing the API server"
  default = "ch4ngem3"
}

variable bastion_host {
  description = "Bastion we use to bounce SSH connections into our private network"
}

variable bastion_user {
  description = "If using an LX ubuntu image we'll use root, otherwise ubuntu"
  default = "root"
}

variable bastion_public_key {
  description = "Public SSH key for the private key used across all nodes"
}

variable private_network {
  description = "The UUID of a private fabric network"
}

variable public_network {
  description = "The UUID of a public fabric network"
}

variable default_user {
  description = "Default user account typically used to SSH into each machine"
  default = "ubuntu"
}

variable controller_package {
  description = "Package which defines the compute attributes of a controller"
  default = "g4-highcpu-512M"
}

variable worker_package {
  description = "Package which defines the compute attributes of a worker"
  default = "k4-highcpu-kvm-1.75G"
}

variable controller_image {
  description = "The UUID of your k8s-controller-lx-16.04 image"
}

variable worker_image {
  description = "The UUID of your k8s-worker-kvm-16.04 image"
}

variable etcd1_ip {
  description = "IP address of your etcd cluster node 1"
}

variable etcd2_ip {
  description = "IP address of your etcd cluster node 2"
}

variable etcd3_ip {
  description = "IP address of your etcd cluster node 3"
}
