# k8s-bare-metal

Guide for running Kubernetes on Triton using Packer and Terraform running on a
Joyent Triton bare metal container and KVM instance.

The initial goal of this guide is to build out the following instances akin to
the Hard Way post but with extended Triton exclusive features.

- 1x `controller` infrastructure container running `kube-apiserver`,
  `kube-controller-manager`, and `kube-scheduler`.
- 1x `worker` running KVM for `kubelet`, `kube-proxy`, and `docker`.
- 1x `bastion` node for bridging into the private network.
- `etcd` cluster provided by the Autopilot Pattern

## Dependencies

Install Packer 1.1.0.

Install Terraform 0.9.6.

Install the [Triton CLI tool](https://docs.joyent.com/public-cloud/api-access/cloudapi).

Certificates are created via CloudFlare's PKI toolkit, [`cfssl`](https://cfssl.org/).

I use [`jq`](https://stedolan.github.io/jq/) below for pulling information.

I also use [`direnv`](https://direnv.net/) for storing environment variables used by this project.

### Note on Packer

Packer templates in this project require JSON5 support in `packer(1)` or the
`cfgt(1)` utility.

- Usage with unpatched packer: `cfgt -i kvm-worker.json5 | packer build -`
- Usage with patched packer: `packer build kvm-worker.json5`

[packer w/ JSON5 support](https://github.com/sean-/packer/tree/f-json5)
cfgt: `go get -u github.com/sean-/cfgt`

## Setup your Triton CLI tool

```sh
$ eval "$(triton env us-sw-1)"
$ env | grep SDC
SDC_ACCOUNT=test-user
SDC_KEY_ID=22:45:7d:1c:f5:f0:b9:13:14:d9:ad:9d:aa:1c:83:44
SDC_KEY_PATH=/Users/test-user/.ssh/id_rsa
SDC_URL=https://us-sw-1.api.joyent.com
```

## Create a private fabric network

* In the Triton dashboard, create a private fabric network with the following
  configuration.
* Also, set it as your default Docker network.

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

* Make sure your new private fabric network is the default network for Docker
  containers under the Joyent Public Cloud Portal. This helps support creating
  all of our non-public etcd containers in the correct network through Docker
  Compose.
* `git clone git@github.com:autopilotpattern/etcd.git && cd etcd` and run
  `./start.sh`
* Your cluster should bootstrap on its own.
* Note your cluster IP addresses, I use the following rather obtuse line of
  shell.

```sh
$ triton-docker inspect $(triton-docker ps --format "{{.Names}}" --filter 'name=e_etcd') | jq -r '.[].NetworkSettings.IPAddress'
```

## Create Kubernetes images using Packer

Next, we'll use Packer to prebuild some of the utilities and tooling required by
the remainder of the process. This helps cut down on setup time else where,
especially when adding more nodes.

First create a bastion for securing our build environment, then build an image
for each part of our Kubernetes cluster.

1. Run `make build/bastion` to build a bastion image.
1. `triton create --wait --name=fubarnetes --network=Joyent-SDC-Public,fubarnetes -m user-data="hostname=fubarnetes" k8s-bastion-lx-16.04 14ad9d54`
1. Note the IP address of your bastion instance and set it to `export BASTION_HOST` env var.
1. Use bastion instance to build remaining images on your private fabric network.
1. Run `make build/controller build/worker`

## Provision infrastructure using Terraform

Next, we'll use Terraform to create the instances we'll be deploying Kubernetes
onto, both the `controller` and `worker`. This will interface with the Triton
API and create our nodes.

1. Create input variables for Terraform within `.terraform.vars` by copying the
   sample `.terraform.vars.example` file.
1. Run `make plan` first and make sure everything is configured.
1. `make apply` when ready to create your infrastructure.

## Run Ansible to upload assets and restart the cluster

After we've created our infrastructure we're left with a few files that need to
be uploaded to our nodes. We'll use Ansible to upload them and restart
Kubernetes services. We'll make use of our bastion instance to bounce into our
private network.

Since the configuration files and TLS certs are automatically generated, we
simply need to run Ansible.

Ansible performs the following...

1. Uploads generated configs and certificates onto remote machines.
1. Restarts services
1. Creates VXLAN networking and routes based on `kubectl get nodes`

## Notes

- Generated JSON files in this project are treated as ephemeral build
  assets. They're deleted during most `make build` steps.
- When debugging packer use `PACKER_LOG=1 make build/worker`.
- When working with Ubuntu images on Triton, note the difference between
  [default SSH users][default]. On Ubuntu Certified images the default user is
  `ubuntu`, on Joyent built Ubuntu images use `root`.

[default]: https://github.com/joyent/node-triton/issues/3#issuecomment-136519245

## Configuration

The following is a list of configuration files required/generated by the
process. Most of these are generated for you by Terraform.

###  /var/lib/kubernetes/authorization-policy.jsonl

Install on `controller` (`kube-apiserver`) nodes.
Static file, no dynamic values.

###  /var/lib/kubernetes/token.csv

Any machine with `kube-apiserver` or `kubectl`.
Includes token generated as a sort of password.

### /etc/systemd/system/kube-apiserver.service

`scripts/start-kube-apiserver.sh` => `/usr/local/sbin`

Self IP address.
`etcd` cluster addresses.
Total number of API servers.
Includes list of controller IPs and port `2379`

Upload auth policy to `/var/lib/kubernetes`
Upload TLS docs into `/var/lib/kubernetes`
Upload tokens file into `/var/lib/kubernetes`

No dependencies on other instances, can be cleanly generated.

```
https://10.240.0.8:2379,https://10.240.0.12:2379,https://10.240.0.13:2379
```

### /etc/systemd/system/kube-controller-manager.service

`scripts/start-kube-controller-manager.sh` => `/usr/local/sbin`

No dependencies on other instances, can be cleanly installed.

### /etc/systemd/system/kube-scheduler.service

`scripts/start-kube-scheduler.sh` => `/usr/local/sbin`

No dependencies on other instances, can be cleanly installed.

### /etc/systemd/system/kube-proxy.service

`scripts/start-kube-proxy.sh` => `/usr/local/sbin`

Master controller IP.

### /var/lib/kubelet/kubeconfig

Installed on workers.
Requires controller0 IP.
Requires token used for API auth.

Depends on API servers being setup.

`https://10.240.0.8:6443,https://10.240.0.12:6443,https://10.240.0.13:6443`

### /var/lib/kubernetes/ca.pem

TLS uploads after provisioning from the bastion.

### /var/lib/kubernetes/kubernetes-key.pem

TLS uploads after provisioning from the bastion.

### /var/lib/kubernetes/kubernetes.pem

TLS uploads after provisioning from the bastion.

### Setup TLS

```sh
$ mkdir -p /var/lib/kubernetes
$ cp ca.pem kubernetes-key.pem kubernetes.pem /var/lib/kubernetes/
```
