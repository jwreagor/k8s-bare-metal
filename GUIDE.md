# k8s-bare-metal

Guide for running Kubernetes on Triton using Packer and Terraform.

The initial goal of this guide is to build out the following instances akin to
the Hard Way post, but with extended Triton exclusive features.

- 1x `controller` infrastructure container running `kube-apiserver`,
  `kube-controller-manager`, and `kube-scheduler`.
- 1x `worker` running KVM for `kubelet`, `kube-proxy`, and `docker`.
- 1x `edge worker` running KVM for `kubelet`, `kube-proxy`, and `docker`.
- 1x `bastion` node for bridging into the private network.
- `etcd` cluster using updated autopilot pattern
- Ignore TLS requirement for the moment

## Setup

* Spin-up `etcd` Autopilot Pattern cluster (within our private network).
* In the Triton dashboard, create a private fabric network with the following setup.

```json
{
    "name": "fubarnetes",
    "public": false,
    "fabric": true,
    "gateway": "10.20.0.1",
    "internet_nat": true,
    "provision_end_ip": "10.20.0.254",
    "provision_start_ip": "10.20.0.2",
    "resolvers": [
        "8.8.8.8",
        "8.8.4.4"
    ],
    "routes": {},
    "subnet": "10.20.0.0/24",
    "vlan_id": 2
}
```
* Edit each template and add the network UUID you've created below.

## Usage

1. Run `make build/bastion` to build a bastion image.
2. `triton create --wait --name=fubarnetes --network=Joyent-SDC-Public,fubarnetes -m user-data="hostname=fubarnetes" k8s-bastion-lx-16.04 14ad9d54`
3. Grab the IP address of your bastion instance and set to `export BASTION_HOST` env var.
4. Use bastion instance to build remaining images for your private fabric network.
5. Run `make build/controller build/edge build/worker`
6. Create input variables for Terraform.
7. Configure infrastructure using Terraform `terraform plan`
8. `terraform apply`

## Notes

- Generated JSON files in this project are treated as ephemeral build
  assets. They're deleted during most `make build` steps.
- When debugging packer use `PACKER_LOG=1 make build/worker`.
