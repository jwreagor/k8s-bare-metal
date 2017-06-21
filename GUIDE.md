# k8s-bare-metal

Guide for running Kubernetes on Triton using Packer and Terraform.

The initial goal of this guide is to build out the following instances akin to
the Hard Way post but with extended Triton exclusive features.

- 1x `controller` infrastructure container running `kube-apiserver`,
  `kube-controller-manager`, and `kube-scheduler`.
- 1x `worker` running KVM for `kubelet`, `kube-proxy`, and `docker`.
- 1x `edge worker` running KVM for `kubelet`, `kube-proxy`, and `docker`.
- 1x `bastion` node for bridging into the private network.
- `etcd` cluster using the Autopilot Pattern
- Ignore TLS requirement for the moment...

## Create a private fabric network

* In the Triton dashboard, create a private fabric network with the following
  configuration.

```json
{
    "id": "00000000-0000-0000-0000-000000000001",
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

* Set our private network's UUID as an environment variable to `export PRIVATE_NETWORK=$(triton network get fubarnetes | jq -r .id)`
* We'll also set Joyent's public network UUID to `export PUBLIC_NETWORK=$(triton network get Joyent-SDC-Public | jq -r .id)`

## Create your etcd cluster

This is a great chance to use the Autopilot Pattern etcd project to spin-up a
private etcd cluster for our Kubernetes services.

* Set your new private network to be the default for Docker containers under the
  Joyent Public Cloud Portal. This helps support easily rolling out etcd by
  creating all of our non-public containers in the correct network through
  Docker Compose.
* `git clone git@github.com:autopilotpattern/etcd.git && cd etcd` and run
  `./start.sh`
* Your cluster should bootstrap on its own.

## Create your Kubernetes images using Packer

We'll first create a bastion for securely building our images then build an
image for each portion of our Kubernetes cluster.

1. Run `make build/bastion` to build a bastionimage.
1. `triton create --wait --name=fubarnetes --network=Joyent-SDC-Public,fubarnetes -m user-data="hostname=fubarnetes" k8s-bastion-lx-16.04 14ad9d54`
1. Grab the IP address of your bastion instance and set to `export BASTION_HOST` env var.
1. Use bastion instance to build remaining images on your private fabric network.
1. Run `make build/controller build/edge build/worker`

## Provision your infrastructure using Terraform

1. Create input variables for Terraform within `.terraform.vars`.
1. Configure infrastructure using Terraform `terraform plan`
1. `terraform apply`

## Notes

- Generated JSON files in this project are treated as ephemeral build
  assets. They're deleted during most `make build` steps.
- When debugging packer use `PACKER_LOG=1 make build/worker`.
- When working with ubuntu images on Triton, please note the difference between
  [default SSH users][default]. On ubuntu certified images the default user is
  `ubuntu`, on Joyent built ubuntu images use `root`.

[default]: https://github.com/joyent/node-triton/issues/3#issuecomment-136519245
