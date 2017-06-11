variable triton_account {
  description = "The same SDC_ACCOUNT used by the triton CLI"
}

variable triton_key_id {
  description = "The same SDC_KEY_ID used by the triton CLI"
}

variable triton_url {
  description = "The same SDC_URL used by the triton CLI"
}

variable triton_key_path {
  description = "Path to the SSH private key used by triton"
}

variable bastion_public_key {
  description = "Public SSH key for the private key used across all nodes"
}

# NOTE: IF YOU CHANGE THIS YOU HAVE TO CHANGE
# instance_filters = tag:ansibleFilter=Kubernetes01 in ./ansible/hosts/ec2.ini
variable ansibleFilter {
  description = "`ansibleFilter` tag added to all nodes, enables instance filtering by ansible inventory"
  default = "Kubernetes01"
}

variable default_user {
  description = "Default user account typically used to SSH into each machine"
  default = "ubuntu"
}

# NOTE: LX branded zones
variable etcd_package {
  default = "g4-highcpu-512M"
}
variable etcd_image {
  default = "7b5981c4-1889-11e7-b4c5-3f3bdfc9b88b"
}

# NOTE: LX branded zones
variable controller_package {
  default = "g4-highcpu-512M"
}
variable controller_image {
  default = "7b5981c4-1889-11e7-b4c5-3f3bdfc9b88b"
}

# NOTE: LX branded zones
variable bastion_package {
  default = "g4-highcpu-512M"
}
variable bastion_image {
  default = "7b5981c4-1889-11e7-b4c5-3f3bdfc9b88b"
}

# NOTE: KVM images
variable worker_package {
  default = "k4-highcpu-kvm-1.75G"
}
variable worker_image {
  default = "554abb2e-a957-4b51-a601-97c934eadf33"
}

# NOTE: KVM images
variable edge_worker_package {
  default = "k4-highcpu-kvm-1.75G"
}
variable edge_worker_image {
  default = "554abb2e-a957-4b51-a601-97c934eadf33"
}
